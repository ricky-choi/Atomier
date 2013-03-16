//
//  ContentOrganizer.m
//  ReaderStandard
//
//  Created by Choi Jaeyoung on 12/12/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import "ContentOrganizer.h"
#import "Element.h"
#import "DocumentRoot.h"
#import "ASIHTTPRequest.h"

#define SAVE_QUEUE "com.felaur.readerstandard.contentsave"
#define IMAGE_DOWNLOAD_QUEUE "com.felaur.readerstandard.imagedownload"

#define SUMMARY_MAX_LENGTH 350

@implementation ContentOrganizer {
	dispatch_queue_t contentSaveQueue;
	dispatch_queue_t imageDownloadQueue;
}

+ (id)sharedInstance {
	static ContentOrganizer *sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[ContentOrganizer alloc] init];
	});
	return sharedInstance;
}

- (NSURL *)cacheFolder {
	return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)iconFolder {
	return [[self cacheFolder] URLByAppendingPathComponent:@"icon" isDirectory:YES];
}

- (NSURL *)touchIconFolder {
	return [[self cacheFolder] URLByAppendingPathComponent:@"touchicon" isDirectory:YES];
}

- (NSURL *)contentFolder {
	return [[self cacheFolder] URLByAppendingPathComponent:@"Feeds" isDirectory:YES];
}

- (NSURL *)feedFolderForID:(NSString *)contentID {
	return [[self contentFolder] URLByAppendingPathComponent:contentID isDirectory:YES];
}

- (NSURL *)feedContentURLForID:(NSString *)contentID {
	return [[self feedFolderForID:contentID] URLByAppendingPathComponent:@"content" isDirectory:NO];
}

- (NSURL *)cacheFeedContentURLForID:(NSString *)contentID {
	return [[self feedFolderForID:contentID] URLByAppendingPathComponent:@"contentc" isDirectory:NO];
}

- (NSURL *)feedSummaryURLForID:(NSString *)contentID {
	return [[self feedFolderForID:contentID] URLByAppendingPathComponent:@"summary" isDirectory:NO];
}

- (NSURL *)feedFirstImageURLForID:(NSString *)contentID {
	return [[self feedFolderForID:contentID] URLByAppendingPathComponent:@"image" isDirectory:NO];
}

- (void)save:(NSString *)contentString forID:(NSString *)contentID {
	if (contentSaveQueue == nil) {
		contentSaveQueue = dispatch_queue_create(SAVE_QUEUE, NULL);
	}
	
	dispatch_async(contentSaveQueue, ^{
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSURL *feedFolder = [self feedFolderForID:contentID];
		if ([fileManager fileExistsAtPath:[feedFolder path]] == NO) {
			[fileManager createDirectoryAtURL:feedFolder withIntermediateDirectories:YES attributes:nil error:nil];
		}
		
		NSError *error;
		[contentString writeToURL:[self feedContentURLForID:contentID] 
						  atomically:YES
							encoding:NSUTF8StringEncoding
							   error:&error];
		if (error) {
			NSLog(@"save error: %@", [error userInfo]);
		}
	});
}

- (void)saveForChche:(NSString *)contentString forID:(NSString *)contentID {
	if (contentSaveQueue == nil) {
		contentSaveQueue = dispatch_queue_create(SAVE_QUEUE, NULL);
	}
	
	dispatch_async(contentSaveQueue, ^{
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSURL *feedFolder = [self feedFolderForID:contentID];
		if ([fileManager fileExistsAtPath:[feedFolder path]] == NO) {
			[fileManager createDirectoryAtURL:feedFolder withIntermediateDirectories:YES attributes:nil error:nil];
		}
		
		
		
		NSError *error;
		[contentString writeToURL:[self cacheFeedContentURLForID:contentID] 
					   atomically:YES
						 encoding:NSUTF8StringEncoding
							error:&error];
		if (error) {
			NSLog(@"save error: %@", [error userInfo]);
		}
	});
}

- (NSString *)contentForID:(NSString *)contentID {
	NSError *error;
	NSString *content = [[NSString alloc] initWithContentsOfURL:[self feedContentURLForID:contentID]
													   encoding:NSUTF8StringEncoding
														  error:&error];
	if (error) {
		NSLog(@"load content error: %@", [error userInfo]);
		return nil;
	}
	
	return content;
}

- (void)saveSummary:(NSString *)summaryString forID:(NSString *)contentID {
	if (contentSaveQueue == nil) {
		contentSaveQueue = dispatch_queue_create(SAVE_QUEUE, NULL);
	}
	
	dispatch_async(contentSaveQueue, ^{
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSURL *feedFolder = [self feedFolderForID:contentID];
		if ([fileManager fileExistsAtPath:[feedFolder path]] == NO) {
			[fileManager createDirectoryAtURL:feedFolder withIntermediateDirectories:YES attributes:nil error:nil];
		}
		
		NSError *error;
		[summaryString writeToURL:[self feedSummaryURLForID:contentID] 
					   atomically:YES
						 encoding:NSUTF8StringEncoding
							error:&error];
		if (error) {
			NSLog(@"save error: %@", [error userInfo]);
		}
		else {
			NSLog(@"save summary done: %@", summaryString);
		}
	});
}

- (NSString *)summaryForID:(NSString *)contentID {

	NSURL *summaryURL = [self feedSummaryURLForID:contentID];
	NSString *summary = [[NSString alloc] initWithContentsOfURL:summaryURL
													   encoding:NSUTF8StringEncoding
														  error:nil];
	if (summary == nil) {

		// content 로부터 summary 추출
		NSString *contentHTML = [self contentForID:contentID];
		if (contentHTML) {
			DocumentRoot* document = [Element parseHTML: contentHTML];
			NSString *contentsText = document.contentsText;

			if ([contentsText length] > SUMMARY_MAX_LENGTH) {
				summary = [contentsText substringToIndex:SUMMARY_MAX_LENGTH];
			} else {
				summary = contentsText;
			}                                                                       
		}
		
		if (!summary) {
			summary = @"";
		}
		[self saveSummary:summary forID:contentID];
	}	
	
	return summary;
}

- (void)downloadImageByInfo:(NSDictionary *)imageInfo forID:(NSString *)contentID {
	
	NSString *imageURL = [imageInfo objectForKey:@"src"];
	NSLog(@"start image download(%@) : %@", contentID, imageURL);
	if (imageURL == nil) {
		return;
	}
	
	if (imageDownloadQueue == nil) {
		imageDownloadQueue = dispatch_queue_create(IMAGE_DOWNLOAD_QUEUE, NULL);
	}
	
	dispatch_async(imageDownloadQueue, ^{
		ASIHTTPRequest *httpRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imageURL]];
		[httpRequest startSynchronous];
		
		NSData *imageData = [httpRequest responseData];
		UIImage *image = [UIImage imageWithData:imageData];
		
		NSLog(@"download image completed (%@) ", contentID);
		
		if (image) {
			if ([imageData writeToURL:[self feedFirstImageURLForID:contentID] atomically:YES]) {
				// image 저장 성공
				[[NSNotificationCenter defaultCenter] postNotificationName:@"ImageDownload" 
																	object:image 
																  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																			contentID, @"contentID",
																			imageInfo, @"imageInfo", nil]];			
			}
		}
	});
}

- (void)downloadImageBySource:(NSString *)imageURL forID:(NSString *)contentID {
	if (imageDownloadQueue == nil) {
		imageDownloadQueue = dispatch_queue_create(IMAGE_DOWNLOAD_QUEUE, NULL);
	}
	
	dispatch_async(imageDownloadQueue, ^{
		ASIHTTPRequest *httpRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imageURL]];
		[httpRequest startSynchronous];
		
		NSData *imageData = [httpRequest responseData];
		
		if (imageData) {
			if ([imageData writeToURL:[self feedFirstImageURLForID:contentID] atomically:YES]) {
				// image 저장 성공
				[[NSNotificationCenter defaultCenter] postNotificationName:@"ImageDownload" 
																	object:imageData 
																  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																			contentID, @"contentID", nil]];
			}
		}
	});
}

- (void)makeSummaryAndFirstImageForID:(NSString *)contentID {
	if ([self existSummaryAndFirstImageForID:contentID]) {
		NSLog(@"makeSummaryAndFirstImageForID canceled(%@)", contentID);
		return;
	}
	
	NSLog(@"makeSummaryAndFirstImageForID Start(%@)", contentID);
	
	NSString *contentHTML = [self contentForID:contentID];
	if (contentHTML) {
		DocumentRoot* document = [Element parseHTML: contentHTML];
		
		if ([self existSummaryForID:contentID] == NO) {
			NSLog(@"makeSummaryAndFirstImageForID for summary(%@)", contentID);
			NSString *contentsText = document.contentsText;
			NSString *summary = nil;
			if ([contentsText length] > SUMMARY_MAX_LENGTH) {
				summary = [contentsText substringToIndex:SUMMARY_MAX_LENGTH];
			} else {
				summary = contentsText;
			}
			
			if (summary) {
				[self saveSummary:summary forID:contentID];
			}
		}
		
		if ([self existFirstImageForID:contentID] == NO) {
			NSLog(@"makeSummaryAndFirstImageForID for image(%@)", contentID);
			Element *img = [document selectElement:@"img"];
			if (img) {
				NSDictionary *imageInfo = img.attributes;
				[self downloadImageByInfo:imageInfo forID:contentID];
			}
		}				
	}	
}

- (NSArray *)imagesForID:(NSString *)contentID {
	return nil;
}

- (NSArray *)imageURLsForID:(NSString *)contentID {
	NSString *contentHTML = [self contentForID:contentID];
	if (contentHTML) {
		DocumentRoot* document = [Element parseHTML: contentHTML];		
		NSArray *imgs = [document selectElements:@"img"];
		NSMutableArray *returnArray = [NSMutableArray arrayWithCapacity:[imgs count]];
		for (Element *img in imgs) {
			NSDictionary *imageInfo = img.attributes;
			NSString *imageURLString = [imageInfo objectForKey:@"src"];
			NSURL *imageURL = [NSURL URLWithString:imageURLString];
			if (imageURL) {
				[returnArray addObject:imageURL];
			}
		}
		
		return returnArray;		
	}
	
	return nil;
}

- (UIImage *)firstImageForID:(NSString *)contentID {
	NSURL *imageURL = [self feedFirstImageURLForID:contentID];
	UIImage *image = [UIImage imageWithContentsOfFile:[imageURL path]];
	return image;
}

- (NSURL *)firstImageURLForID:(NSString *)contentID {
	NSString *contentHTML = [self contentForID:contentID];
	if (contentHTML) {
		DocumentRoot* document = [Element parseHTML: contentHTML];		
		Element *img = [document selectElement:@"img"];
		NSDictionary *imageInfo = img.attributes;
		NSString *imageURL = [imageInfo objectForKey:@"src"];
		return [NSURL URLWithString:imageURL];
	}
	
	return nil;
}

- (BOOL)existSummaryAndFirstImageForID:(NSString *)contentID {
	return [self existSummaryForID:contentID] && [self existFirstImageForID:contentID];
}

- (BOOL)existSummaryForID:(NSString *)contentID {
	NSURL *summaryURL = [self feedSummaryURLForID:contentID];
	return [[NSFileManager defaultManager] fileExistsAtPath:[summaryURL path]];
}

- (BOOL)existFirstImageForID:(NSString *)contentID {
	NSURL *imageURL = [self feedFirstImageURLForID:contentID];
	NSLog(@"existFirstImageForID image path: %@", [imageURL path]);
	return [[NSFileManager defaultManager] fileExistsAtPath:[imageURL path]];
}

- (UIImage *)iconForSubscription:(NSString *)host {
	if (host) {
		return [UIImage imageWithContentsOfFile:[[[self iconFolder] URLByAppendingPathComponent:host] path]];
	}
	
	return nil;
}

- (UIImage *)touchIconForSubscription:(NSString *)host {
	if (host) {
		return [UIImage imageWithContentsOfFile:[[[self touchIconFolder] URLByAppendingPathComponent:host] path]];
	}
	
	return nil;
}

- (void)makeIcon:(NSString *)host scheme:(NSString *)scheme {
	[self makeIcon:host scheme:scheme withTouchIcon:NO];
}

/*
 small icon :
 <link href="image url" rel="shortcut icon" type="image/x-icon">
 
 big icon ( for iphone) :
 <link href="image url" rel="apple-touch-icon">
 
 detail
 <link href="image url" rel="apple-touch-icon-precomposed" sizes="57x57">
  <link href="image url" rel="apple-touch-icon-precomposed" sizes="72x72">
  <link href="image url" rel="apple-touch-icon-precomposed" sizes="114X114">
 
 
 
 default name
 
 favicon.ico
 
 apple-touch-icon.png
 apple-touch-icon-precomposed.png
 */

- (void)makeIcon:(NSString *)host scheme:(NSString *)scheme withTouchIcon:(BOOL)touch {
	NSURL *iconSavePath = [[self iconFolder] URLByAppendingPathComponent:host];
	NSURL *touchIconSavePath = [[self touchIconFolder] URLByAppendingPathComponent:host];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:[[self iconFolder] path]] == NO) {
		[fileManager createDirectoryAtURL:[self iconFolder] withIntermediateDirectories:YES attributes:nil error:nil];
	}
	if (touch) {
		if ([fileManager fileExistsAtPath:[[self touchIconFolder] path]] == NO) {
			[fileManager createDirectoryAtURL:[self touchIconFolder] withIntermediateDirectories:YES attributes:nil error:nil];
		}
	}
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		
		NSURL *expectIconURL = [[NSURL alloc] initWithScheme:scheme host:host path:@"/favicon.ico"];
		
		BOOL downloadIconComplete = NO;
		BOOL downloadTouchIconComplete = !touch;
		
		ASIHTTPRequest *httpRequest = [ASIHTTPRequest requestWithURL:expectIconURL];
		[httpRequest startSynchronous];
		
		if ([httpRequest responseStatusCode] == 200) {
			NSData *imageData = [httpRequest responseData];
			
			if (imageData && [imageData length] > 0) {
				if ([imageData writeToURL:iconSavePath atomically:YES]) {
					downloadIconComplete = YES;
				}
			}
		}
		
		if (touch) {
			NSURL *expectTouchIconURL = [[NSURL alloc] initWithScheme:scheme host:host path:@"/apple-touch-icon.png"];
			
			httpRequest = [ASIHTTPRequest requestWithURL:expectTouchIconURL];
			[httpRequest startSynchronous];
			
			if ([httpRequest responseStatusCode] == 200) {
				NSData *imageData = [httpRequest responseData];
				
				if (imageData && [imageData length] > 0) {
					if ([imageData writeToURL:touchIconSavePath atomically:YES]) {
						downloadTouchIconComplete = YES;
					}					
				}
			}
			
			if (downloadTouchIconComplete == NO) {
				NSURL *expectTouchIconURL2 = [[NSURL alloc] initWithScheme:scheme host:host path:@"/apple-touch-icon-precomposed.png"];
				
				httpRequest = [ASIHTTPRequest requestWithURL:expectTouchIconURL2];
				[httpRequest startSynchronous];
				
				if ([httpRequest responseStatusCode] == 200) {
					NSData *imageData = [httpRequest responseData];
					
					if (imageData && [imageData length] > 0) {
						if ([imageData writeToURL:touchIconSavePath atomically:YES]) {
							downloadTouchIconComplete = YES;
						}
					}
				}
			}
		}
		
		
		
		if (downloadIconComplete == NO || downloadTouchIconComplete == NO) {
			NSURL *siteURL = [[NSURL alloc] initWithScheme:scheme host:host path:@"/"];
			
			httpRequest = [ASIHTTPRequest requestWithURL:siteURL];
			[httpRequest startSynchronous];
			
			if ([httpRequest responseStatusCode] == 200) {
				NSString *contentHTML = [httpRequest responseString];
				if (contentHTML) {
					DocumentRoot* document = [Element parseHTML: contentHTML];		
					NSArray *links = [document selectElements:@"link"];
					for (Element *link in links) {
						NSDictionary *linkInfo = link.attributes;
						NSString *linkHref = [linkInfo objectForKey:@"href"];
						NSString *linkKind = [[linkInfo objectForKey:@"rel"] lowercaseString];
						if (downloadIconComplete == NO) {
							if ([linkKind isEqualToString:@"shortcut icon"] || [linkKind isEqualToString:@"icon"]) {
								NSURL *finalIconURL = [NSURL URLWithString:linkHref relativeToURL:httpRequest.url];
								//NSLog(@"finalIcon : %@ + %@ = %@", httpRequest.url, linkHref, finalIconURL);
								
								if (finalIconURL == nil) {
									finalIconURL = [NSURL URLWithString:linkHref];
								}
								
								httpRequest = [ASIHTTPRequest requestWithURL:finalIconURL];
								[httpRequest startSynchronous];
								
								if ([httpRequest responseStatusCode] == 200) {
									NSData *imageData = [httpRequest responseData];
									
									if (imageData && [imageData length] > 0) {
										if ([imageData writeToURL:iconSavePath atomically:YES]) {
											downloadIconComplete = YES;
										}
									}
								}
							}
						}						
						
						if (touch && downloadTouchIconComplete == NO) {
							if ([linkKind isEqualToString:@"apple-touch-icon"] || [linkKind isEqualToString:@"apple-touch-icon-precomposed"]) {
								NSURL *finalTouchIconURL = [NSURL URLWithString:linkHref relativeToURL:httpRequest.url];
								NSLog(@"finalTouchIcon : %@ + %@ = %@", httpRequest.url, linkHref, finalTouchIconURL);
								
								httpRequest = [ASIHTTPRequest requestWithURL:finalTouchIconURL];
								[httpRequest startSynchronous];
								
								if ([httpRequest responseStatusCode] == 200) {
									NSData *imageData = [httpRequest responseData];
									
									if (imageData && [imageData length] > 0) {
										if ([imageData writeToURL:touchIconSavePath atomically:YES]) {
											downloadTouchIconComplete = YES;
										}
									}
								}
							}
						}
					}		
				}
			}
		}
		
	});
}

@end
