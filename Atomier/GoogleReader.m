//
//  GoogleReader.m
//  GoogleReader
//
//  Created by Choi Jaeyoung on 12/2/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import "GoogleReader.h"
#import "ASIFormDataRequest.h"

#define CLIENT @"reader_felaur"
#define DISPATCH_FEED_NAME "com.felaur.readerstandard.feedload"
#define DISPATCH_FEED_MARK "com.felaur.readerstandard.feedmark"

#define GOOGLE_HOST @"www.google.com"
#define GOOGLE_COOKIE @".google.com"
#define USER_TOKEN @"t"
#define USER_AUTH @"a"

@interface GoogleReader ()

@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *auth;

- (void)authenticateFailed:(id)description;
- (void)saveAuthInfo;
- (void)readAuthInfo;
- (NSUInteger)maxSyncNum;

@end

@implementation GoogleReader

@synthesize delegate = _delegate;
@synthesize subscribeDelegate = _subscribeDelegate;

@synthesize mainRequest = _mainRequest;

@synthesize email = _email;
@synthesize password = _password;
@synthesize token = _token;
@synthesize auth = _auth;
@synthesize lastUpdate = _lastUpdate;

@synthesize jsonReadingOptions = _jsonReadingOptions;

+ (id)sharedInstance {
	static GoogleReader *sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[GoogleReader alloc] init];
	});
	return sharedInstance;
}

- (id)init {
	if ((self = [super init])) {
		[self readAuthInfo];
		_jsonReadingOptions = kNilOptions;
	}
	
	return self;
}

#pragma mark -

- (void)saveAuthInfo {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setValue:self.token forKey:USER_TOKEN];
	[userDefaults setValue:self.auth forKey:USER_AUTH];
	[userDefaults synchronize];
}

- (void)readAuthInfo {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	self.token = [userDefaults stringForKey:USER_TOKEN];
	self.auth = [userDefaults stringForKey:USER_AUTH];
}

- (NSString *)httpScheme {
    BOOL needSSL = NO;
    
    if (_delegate && [_delegate respondsToSelector:@selector(isWWAN)]) {
        needSSL = ![_delegate isWWAN];
    }
    
    return (needSSL ? @"https" : @"http");
}

- (NSURL *)httpURLForHost:(NSString *)host andPath:(NSString *)path {
    return [[NSURL alloc] initWithScheme:[self httpScheme] host:host path:path];
}

- (NSURL *)googleURLForPath:(NSString *)path {
    return [[NSURL alloc] initWithScheme:[self httpScheme] host:GOOGLE_HOST path:path];
}

- (NSURL *)httpURLExceptScheme:(NSString *)string {
    NSString *urlString = [NSString stringWithFormat:@"%@://%@", [self httpScheme], string];
    return [NSURL URLWithString:urlString];
}

- (NSURL *)googleURLExceptScheme:(NSString *)string {
    NSString *urlString = [NSString stringWithFormat:@"%@://www.google.com/%@", [self httpScheme], string];
    return [NSURL URLWithString:urlString];
}

- (void)getAuthSmart {
	[self readAuthInfo];
	
	if (self.token && self.auth) {
		
	} else {
		[self requestSession];
	}
}

- (BOOL)isAuth {
	return (self.auth != nil);
}

- (BOOL)isToken {
	return (self.token != nil);
}

- (void)deleteAuth {
	
	self.auth = nil;
	self.token = nil;
	
	[self saveAuthInfo];
}

- (void)deleteIDInfo {
	self.email = nil;
	self.password = nil;
}

- (void)deleteToken {
	self.token = nil;
	
	[self saveAuthInfo];
}

#pragma mark -

- (void)cancelMainRequest {
	if (self.mainRequest) {
		[self.mainRequest clearDelegatesAndCancel];
		self.mainRequest = nil;
	}
}

- (BOOL)cookieExist {
	
	return NO;
}

- (void)requestSession {
	if ([self cookieExist]) {
		return;
	}
	
	if (self.email && self.password) {
		self.auth = nil;
		self.token = nil;
		
		NSString * timestamp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
		
		ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL:[self googleURLForPath:@"/accounts/ClientLogin"]];
		[request setRequestMethod:@"POST"];
		[request setDelegate:self];
		[request setPostValue:[self email] forKey:@"Email"];
		[request setPostValue:[self password] forKey:@"Passwd"];
		[request setPostValue:@"reader" forKey:@"service"];
		[request setPostValue:timestamp forKey:@"ck"];
		[request setDidFinishSelector:@selector(requestSessionDidFinish:)];
		[request setDidFailSelector:@selector(requestSessionDidFail:)];
		[request startAsynchronous];
	}	
}

- (void)requestSessionDidFinish:(ASIHTTPRequest *)request
{
	NSString * html = [request responseString];
	NSLog(@"receive session info: %@", html);
	
	/*
	 SID=DQAAALYAAACDeFD8YBcRCJsz5E6BJBOJzq3z2ZULaEi-YQD1Lq9y6qhYTAj9UBzzGS5UXQcZzuRpCzqofxLtJ0aGytfJBYHNTfhUMF5TktnytchbffHFIWcwlhQJh84bteTBWUZTchIpUJueTVPaoS1jpuuoSFLacKciyKowt7QD3tiH7Yo9oL-YDLGHSFquO4EqIYNEnR0fba4VIGP7YmXtC8DAuPo-APPSH54ckQeNbDVRLQga6VRq22p57JjudfA_QDyrUUE
	 LSID=DQAAALkAAAD7z2s7cwyZTE1ylzW1b_bhJhD1T-cBiTYfBmprqXwDn1MHLXXiWoU7M43Ii9Xqj5t88mDmB0sxG9ZcIXUGtE6ncTSzlBB1ag6HEoTSSYjBfl5pd2PE9fMATDjCkUJ3fyKIvU31N_2_z4OLIShC4Ayic7uRGWOCxIRDEAZHx5qqn-C6MTinTi0t0cotpoT_QXipl9Dr80EqDnjCyurBsXzCAaAI3cX-arHuHa15RHq6NWGk1FalwFOOJ8R4SyEP39I
	 Auth=DQAAALkAAAD7z2s7cwyZTE1ylzW1b_bhJhD1T-cBiTYfBmprqXwDn1MHLXXiWoU7M43Ii9Xqj5sniW9ZnBYtkPjtukeffZsSadI1zKgRHAZrLVJNT0oRw6Hypon-89eeKIRmj43t-SaUNJmtMjfYs0xJqLC9mfziiN30SE5ZIEg-LWK3Wgq05U-smzcmeUUb51obeo483UHGTOHPw0YnDmAP_dSSScqhx9V7omT56o7qe6LoSuCTd310LHZkQbg95dqYS13ctQg
	 */
	
	/*
	 Error=BadAuthentication
	 */
	
	if (html == nil) {
		[self authenticateFailed:@"Unknown"];
	}
	
	NSArray * items = [html componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	NSMutableDictionary *sessionInfo = [NSMutableDictionary dictionaryWithCapacity:3];
	for (NSString *item in items) {
		NSArray  * parts = [item componentsSeparatedByString:@"="];
		if ([parts count] == 2) {
			NSString * name  = [parts objectAtIndex:0];
			NSString * value = [parts objectAtIndex:1];
			
			[sessionInfo setValue:value forKey:name];
		}
	}
	
	if ([sessionInfo count] > 0) {
		NSLog(@"Session Info : %@", sessionInfo);
		
		NSString *errorCode = [sessionInfo objectForKey:@"Error"];
		if (errorCode) {
			// error
			NSLog(@"Error : %@", errorCode);
			[self authenticateFailed:sessionInfo];
		}
		else {
			// normal
			NSString *authValue = [sessionInfo objectForKey:@"Auth"];
			if (authValue) {
				self.auth = authValue;
				[self requestToken];
			}
			else {
				[self authenticateFailed:@"Unknown"];
			}
		}
	}
	else {
		[self authenticateFailed:@"Unknown"];
	}
}

- (void)requestSessionDidFail:(ASIHTTPRequest *)request
{
	NSLog(@"Request Session Did Fail: %@", [[request error] localizedDescription]);
	[self authenticateFailed:[[request error] localizedDescription]];
}

- (void)authenticateFailed:(id)description {
	NSLog(@"authenticateFailed: %@", description);
	
	NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	for (NSHTTPCookie *cookie in [storage cookies]) {
		[storage deleteCookie:cookie];
	}
	
	[self deleteAuth];
	
	if (_delegate && [_delegate respondsToSelector:@selector(googleReaderAuthenticateFailed:)]) {
		[_delegate googleReaderAuthenticateFailed:description];
	}
}

- (void)requestToken {
	NSLog(@"Request Token Start");
	
	if (self.auth == nil) {
		NSLog(@"request token failed : none of auth");
		return;
	}
	
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
	dispatch_async(queue, ^{
		ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[self googleURLForPath:@"/reader/api/0/token"]];
		[request setRequestMethod:@"GET"];
		[request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"GoogleLogin auth=%@", [self auth]]];
		[request startSynchronous];
		
		NSError *error = [request error];
		if (error) {
			NSLog(@"requestToken error: %@", [error description]);
			dispatch_async(dispatch_get_main_queue(), ^{
				if (_delegate && [_delegate respondsToSelector:@selector(googleReaderRequestTokenFailed)]) {
					[_delegate googleReaderRequestTokenFailed];
				}
			});
		} else {
			if([request responseStatusCode] == 200) {
				NSString * html = [request responseString];
				NSLog(@"get token: %@", html);
				if (html && [html length] > 0) {
					[self setToken:html];
					
					[self saveAuthInfo];
					
					dispatch_async(dispatch_get_main_queue(), ^{
						if (_delegate && [_delegate respondsToSelector:@selector(googleReaderAuthenticateSuccess)]) {
							[_delegate googleReaderAuthenticateSuccess];
						}
					});			
				}
			}
			else {
				dispatch_async(dispatch_get_main_queue(), ^{
					if (_delegate && [_delegate respondsToSelector:@selector(googleReaderRequestTokenFailed)]) {
						[_delegate googleReaderRequestTokenFailed];
					}
				});
			}
		}
	});	
}

#pragma mark -

// TEST RSS: http://cocoacast.com/?q=rss.xml

- (void)quickSubscribeToRSSFeedURL:(NSString *)feedURL moreSearch:(BOOL)more {
	if (self.auth == nil || self.token == nil || feedURL == nil) {
		return;
	}
	
	dispatch_queue_t queue = dispatch_queue_create(DISPATCH_FEED_NAME, NULL);
	dispatch_async(queue, ^{
		NSString * timestamp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
		NSString *url = [NSString stringWithFormat:@"reader/api/0/subscription/quickadd?ck=%@&client=%@", timestamp, CLIENT];
		
		ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[self googleURLExceptScheme:url]];
		[request setRequestMethod:@"POST"];
		[request setPostValue:feedURL forKey:@"quickadd"];
		[request setPostValue:[self token] forKey:@"T"];
		[request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"GoogleLogin auth=%@", [self auth]]];
		
		[request startSynchronous];
		
		NSError *error = [request error];
		if (error) {
			NSLog(@"subscribe error: %@ (%@)", [error description], feedURL);
		} else {
			if([request responseStatusCode] == 200) {
				NSData *body = [request responseData];
				id object = [NSJSONSerialization JSONObjectWithData:body
															options:_jsonReadingOptions
															  error:nil];
				if (object && [object isKindOfClass:[NSDictionary class]]) {
					NSLog(@"subscribed: %@", object);
					NSDictionary *returnValue = (NSDictionary *)object;
					int numResults = [[returnValue objectForKey:@"numResults"] intValue];
					if ( numResults <= 0) {
						// 결과가 없다.
						dispatch_async(dispatch_get_main_queue(), ^{
							if (_subscribeDelegate && [_subscribeDelegate respondsToSelector:@selector(googleReaderSubscribeNoResults)]) {
								[_subscribeDelegate googleReaderSubscribeNoResults];
							}
						});
					} 
					else if ( numResults == 1) {
						// subscribe feed done
						dispatch_async(dispatch_get_main_queue(), ^{
							if (_subscribeDelegate && [_subscribeDelegate respondsToSelector:@selector(googleReaderSubscribeDone)]) {
								[_subscribeDelegate googleReaderSubscribeDone];
							}
						});
					}
					else {
						if (more) {
							if ([[returnValue objectForKey:@"moreResults"] intValue] > 0) {
								// exist search results
								dispatch_async(dispatch_get_main_queue(), ^{
									if (_subscribeDelegate && [_subscribeDelegate respondsToSelector:@selector(googleReaderStartSearch)]) {
										[_subscribeDelegate googleReaderStartSearch];
									}
								});
								[self searchKeyword:feedURL];
							}
						} else {
							dispatch_async(dispatch_get_main_queue(), ^{
								if (_subscribeDelegate && [_subscribeDelegate respondsToSelector:@selector(googleReaderSubscribeFailed)]) {
									[_subscribeDelegate googleReaderSubscribeFailed];
								}
							});
						}
					}
				}
			}
		}
		
	});
}

- (void)quickSubscribeToRSSFeedURL:(NSString *)feedURL {
	[self quickSubscribeToRSSFeedURL:feedURL moreSearch:YES];
}

- (void)searchKeyword:(NSString *)keyword start:(int)startPage {
	if (keyword == nil) {
		return;
	}
	
	dispatch_queue_t queue = dispatch_queue_create(DISPATCH_FEED_NAME, NULL);
	dispatch_async(queue, ^{
		NSString * timestamp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
		NSString *url = [NSString stringWithFormat:@"reader/directory/search?q=%@&start=%d&ck=%@&client=%@", keyword, startPage, timestamp, CLIENT];
		
		ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[self googleURLExceptScheme:url]];
		[request setRequestMethod:@"GET"];
		[request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"GoogleLogin auth=%@", [self auth]]];
		[request startSynchronous];
		
		NSError *error = [request error];
		if (error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if (_subscribeDelegate && [_subscribeDelegate respondsToSelector:@selector(googleReaderSearchFailed)]) {
					[_subscribeDelegate googleReaderSearchFailed];
				}
			});
		} else {
			if([request responseStatusCode] == 200) {
				NSString * html = [request responseString];
				
				if (html && [html length] > 0) {
					
					NSRange startRange = [html rangeOfString:@"_DIRECTORY_SEARCH_DATA ="];
					NSString *jsonString = [html substringWithRange:NSMakeRange(startRange.location + startRange.length, html.length - (startRange.location + startRange.length) - 9)];
					
					id object = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
																options:_jsonReadingOptions
																  error:nil];
					if (object && [object isKindOfClass:[NSDictionary class]]) {
						dispatch_async(dispatch_get_main_queue(), ^{
							if (_subscribeDelegate && [_subscribeDelegate respondsToSelector:@selector(googleReaderSearchDone:)]) {
								[_subscribeDelegate googleReaderSearchDone:object];
							}
						});
					}		
				}
			}
			else {
				dispatch_async(dispatch_get_main_queue(), ^{
					if (_subscribeDelegate && [_subscribeDelegate respondsToSelector:@selector(googleReaderSearchFailed)]) {
						[_subscribeDelegate googleReaderSearchFailed];
					}
				});
			}
		}
	});
}

- (void)searchKeyword:(NSString *)keyword {
	[self searchKeyword:keyword start:0];
}

- (void)subscribeToRSSFeedURL:(NSString *)feedURL atCategory:(NSString *)categoryLabel {	
	[self subscribeToRSSFeedURL:feedURL atCategory:categoryLabel forNewFeedName:nil];
}

- (void)subscribeToRSSFeedURL:(NSString *)feedURL atCategory:(NSString *)categoryLabel forNewFeedName:(NSString *)feedName {
	if (categoryLabel == nil) {
		[self quickSubscribeToRSSFeedURL:feedURL];
		return;
	}
	
	if (self.auth == nil || self.token == nil || feedURL == nil) {
		return;
	}
	
	dispatch_queue_t queue = dispatch_queue_create(DISPATCH_FEED_NAME, NULL);
	dispatch_async(queue, ^{
		NSString *url = [NSString stringWithFormat:@"reader/api/0/subscription/edit?client=%@", CLIENT];
		
		ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[self googleURLExceptScheme:url]];
		[request setRequestMethod:@"POST"];
		[request setPostValue:[NSString stringWithFormat:@"feed/%@", feedURL] forKey:@"s"];
		[request setPostValue:@"subscribe" forKey:@"ac"];
		if (feedName && [feedName length] > 0) {
			[request setPostValue:feedName forKey:@"t"];
		}	
		[request setPostValue:[NSString stringWithFormat:@"user/-/label/%@", categoryLabel] forKey:@"a"];
		[request setPostValue:[self token] forKey:@"T"];
		[request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"GoogleLogin auth=%@", [self auth]]];
		
		[request startSynchronous];
		
		NSError *error = [request error];
		if (error) {
			NSLog(@"subscribe error: %@ (%@)", [error description], feedURL);
		} else {
			if([request responseStatusCode] == 200) {
				if ([[request responseString] isEqualToString:@"OK"]) {
					NSLog(@"subscribe done: (%@)%@ at %@", feedName, feedURL, categoryLabel);
				}
				else {
					NSLog(@"subscribe failed");
				}
			}
		}
		
	});
}

- (void)unsubscribeToRSSFeedURL:(NSString *)feedURL {
	if (self.auth == nil || self.token == nil || feedURL == nil) {
		return;
	}
	
	dispatch_queue_t queue = dispatch_queue_create(DISPATCH_FEED_NAME, NULL);
	dispatch_async(queue, ^{
		NSString *url = [NSString stringWithFormat:@"reader/api/0/subscription/edit?client=%@", CLIENT];
		
		ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[self googleURLExceptScheme:url]];
		[request setRequestMethod:@"POST"];
		[request setPostValue:[NSString stringWithFormat:@"%@", feedURL] forKey:@"s"];
		[request setPostValue:@"unsubscribe" forKey:@"ac"];		
		[request setPostValue:[self token] forKey:@"T"];
		[request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"GoogleLogin auth=%@", [self auth]]];
		
		[request startSynchronous];
		
		NSError *error = [request error];
		if (error) {
			NSLog(@"unsubscribe error: %@ (%@)", [error description], feedURL);
		} else {
			if([request responseStatusCode] == 200) {
				if ([[request responseString] isEqualToString:@"OK"]) {
					NSLog(@"unscribe done: %@", feedURL);
				}
				else {
					NSLog(@"unscribe failed");
				}
			}
		}
		
	});
}

- (void)renameRSSFeedURL:(NSString *)feedURL forNewFeedName:(NSString *)feedName {
	if (self.auth == nil || self.token == nil || feedURL == nil || feedName == nil) {
		return;
	}
	
	dispatch_queue_t queue = dispatch_queue_create(DISPATCH_FEED_NAME, NULL);
	dispatch_async(queue, ^{
		NSString *url = [NSString stringWithFormat:@"reader/api/0/subscription/edit?client=%@", CLIENT];
		
		ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[self googleURLExceptScheme:url]];
		[request setRequestMethod:@"POST"];
		[request setPostValue:[NSString stringWithFormat:@"feed/%@", feedURL] forKey:@"s"];
		[request setPostValue:@"edit" forKey:@"ac"];
		[request setPostValue:feedName forKey:@"t"];
		[request setPostValue:[self token] forKey:@"T"];
		[request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"GoogleLogin auth=%@", [self auth]]];
		
		[request startSynchronous];
		
		NSError *error = [request error];
		if (error) {
			NSLog(@"rename error: %@ (%@)", [error description], feedURL);
		} else {
			if([request responseStatusCode] == 200) {
				if ([[request responseString] isEqualToString:@"OK"]) {
					NSLog(@"rename done: %@", feedURL);
				}
				else {
					NSLog(@"rename failed");
				}
			}
		}
		
	});
}

- (void)editCategoryRSSFeedURL:(NSString *)feedURL toCategory:(NSString *)newCategory {
	[self editCategoryRSSFeedURL:feedURL fromCategory:nil toCategory:newCategory];
}

- (void)editCategoryRSSFeedURL:(NSString *)feedURL fromCategory:(NSString *)oldCategory toCategory:(NSString *)newCategory {
	if (self.auth == nil || self.token == nil || feedURL == nil || newCategory == nil) {
		return;
	}
	
	dispatch_queue_t queue = dispatch_queue_create(DISPATCH_FEED_NAME, NULL);
	dispatch_async(queue, ^{
		NSString *url = [NSString stringWithFormat:@"reader/api/0/subscription/edit?client=%@", CLIENT];
		
		ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[self googleURLExceptScheme:url]];
		[request setRequestMethod:@"POST"];
		[request setPostValue:[NSString stringWithFormat:@"feed/%@", feedURL] forKey:@"s"];
		[request setPostValue:@"edit" forKey:@"ac"];
		if (oldCategory) {
			[request setPostValue:[NSString stringWithFormat:@"user/-/label/%@", oldCategory] forKey:@"r"];
		}
		[request setPostValue:[NSString stringWithFormat:@"user/-/label/%@", newCategory] forKey:@"a"];
		[request setPostValue:[self token] forKey:@"T"];
		[request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"GoogleLogin auth=%@", [self auth]]];
		
		[request startSynchronous];
		
		NSError *error = [request error];
		if (error) {
			NSLog(@"editCategory error: %@ (%@)", [error description], feedURL);
		} else {
			if([request responseStatusCode] == 200) {
				if ([[request responseString] isEqualToString:@"OK"]) {
					NSLog(@"editCategory done: %@(from: %@ to: %@)", feedURL, oldCategory, newCategory);
				}
				else {
					NSLog(@"editCategory failed");
				}
			}
		}
		
	});
}

- (void)deleteRSSFeedURL:(NSString *)feedURL fromCategory:(NSString *)category {
	if (self.auth == nil || self.token == nil || feedURL == nil || category == nil) {
		return;
	}
	
	dispatch_queue_t queue = dispatch_queue_create(DISPATCH_FEED_NAME, NULL);
	dispatch_async(queue, ^{
		NSString *url = [NSString stringWithFormat:@"reader/api/0/subscription/edit?client=%@", CLIENT];
		
		ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[self googleURLExceptScheme:url]];
		[request setRequestMethod:@"POST"];
		[request setPostValue:[NSString stringWithFormat:@"feed/%@", feedURL] forKey:@"s"];
		[request setPostValue:@"edit" forKey:@"ac"];
		[request setPostValue:[NSString stringWithFormat:@"user/-/label/%@", category] forKey:@"r"];
		[request setPostValue:[self token] forKey:@"T"];
		[request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"GoogleLogin auth=%@", [self auth]]];
		
		[request startSynchronous];
		
		NSError *error = [request error];
		if (error) {
			NSLog(@"delete from category error: %@ (%@)", [error description], feedURL);
		} else {
			if([request responseStatusCode] == 200) {
				if ([[request responseString] isEqualToString:@"OK"]) {
					NSLog(@"delete from category done: %@(from: %@)", feedURL, category);
				}
				else {
					NSLog(@"delete from category failed");
				}
			}
		}
		
	});
}

- (void)getUnreadCount {
	if (self.auth == nil) {
		return;
	}
	
	dispatch_queue_t queue = dispatch_queue_create(DISPATCH_FEED_NAME, NULL);
	dispatch_async(queue, ^{
		NSString * timestamp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
		NSString * url = [NSString stringWithFormat:@"reader/api/0/unread-count?allcomments=false&output=json&ck=%@&client=%@", timestamp, CLIENT];
		
		ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[self googleURLExceptScheme:url]];
		[request setRequestMethod:@"GET"];
		[request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"GoogleLogin auth=%@", [self auth]]];
		
		[request startSynchronous];
		
		NSError *error = [request error];
		if (error) {
			NSLog(@"getUnreadList error: %@", [error description]);
		} else {
			if([request responseStatusCode] == 200) {
				NSData *body = [request responseData];
				id object = [NSJSONSerialization JSONObjectWithData:body
															options:_jsonReadingOptions
															  error:nil];
				if (object && [object isKindOfClass:[NSDictionary class]]) {
					NSArray *unreadcounts = [object objectForKey:@"unreadcounts"];
					
					NSMutableArray * filteredSubscription = [NSMutableArray array];
					NSMutableArray * filteredLabel = [NSMutableArray array];
					for (NSDictionary *unreads in unreadcounts) {
						if ([[unreads objectForKey:@"id"] hasPrefix:@"feed/"]) {
							[filteredSubscription addObject:unreads];
						}
						else if ([[unreads objectForKey:@"id"] hasPrefix:@"user/"]) {
							[filteredLabel addObject:unreads];
						}
					}
					//NSLog(@"all unread label: %@", filteredLabel);
					//NSLog(@"all unread subscriptions: %@", filteredSubscription);
					if (_delegate && [_delegate respondsToSelector:@selector(googleReaderUnreadCountDidDownloadForLabel:forSubscription:)] ) {
						dispatch_sync(dispatch_get_main_queue(), ^{
							[_delegate googleReaderUnreadCountDidDownloadForLabel:filteredLabel forSubscription:filteredSubscription];
						});
						//[_delegate googleReaderUnreadCountDidDownloadForLabel:filteredLabel forSubscription:filteredSubscription];
					}
				}
			}
		}		
	});

}

- (NSUInteger)maxSyncNum {
	return 1000;
}

- (NSString *)lastUpdateTime {
//	if (self.lastUpdate) {
//		return [NSString stringWithFormat:@"%d", (long)[self.lastUpdate timeIntervalSince1970]];
//	}
	
	return @"0";
}

#define MAIN_ASYNC 1

- (void)getUnreadList {
	if (self.auth == nil) {
		return;
	}
	
#if MAIN_ASYNC
	
	NSString * timestamp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
	NSString * url = [NSString stringWithFormat:@"reader/api/0/stream/contents/user/-/state/com.google/reading-list?ot=%@&r=n&ck=%@&xt=user/-/state/com.google/read&n=%d&client=%@", [self lastUpdateTime], timestamp, [self maxSyncNum], CLIENT];
	
	self.lastUpdate = [NSDate date];
	
	ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[self googleURLExceptScheme:url]];
	[request setRequestMethod:@"GET"];
	[request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"GoogleLogin auth=%@", [self auth]]];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(getUnreadDidFinish:)];
	[request setDidFailSelector:@selector(getUnreadDidFail:)];
	
	self.mainRequest = request;
	
	[request startAsynchronous];
	
#else
	
	dispatch_queue_t queue = dispatch_queue_create(DISPATCH_FEED_NAME, NULL);
	dispatch_async(queue, ^{
		NSString * timestamp = [NSString stringWithFormat:@"%d", (long)[[NSDate date] timeIntervalSince1970]];
		NSString * url = [NSString stringWithFormat:@"reader/api/0/stream/contents/user/-/state/com.google/reading-list?ot=%@&r=n&ck=%@&xt=user/-/state/com.google/read&n=%d&client=%@", [self lastUpdateTime], timestamp, [self maxSyncNum], CLIENT];
		
		self.lastUpdate = [NSDate date];
		
		ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[self googleURLExceptScheme:url]];
		[request setRequestMethod:@"GET"];
		[request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"GoogleLogin auth=%@", [self auth]]];
		
		[request startSynchronous];
		
		NSError *error = [request error];
		if (error) {
			NSLog(@"getAllFeeds error: %@", [error description]);
			if (_delegate && [_delegate respondsToSelector:@selector(googleReaderDownloadFailed:)]) {
				dispatch_sync(dispatch_get_main_queue(), ^{
					[_delegate googleReaderDownloadFailed:error];
				});
			}
		} else {
			if([request responseStatusCode] == 200) {
				NSData *body = [request responseData];
				id object = [NSJSONSerialization JSONObjectWithData:body
															options:_jsonReadingOptions
															  error:nil];
				if (object && [object isKindOfClass:[NSDictionary class]]) {
					NSArray *list = [object objectForKey:@"items"];
					//NSLog(@"all UnreadList download done(%d): %@", [list count], list);
					if (_delegate && [_delegate respondsToSelector:@selector(googleReaderUnreadsDidDownload:)]) {
						dispatch_sync(dispatch_get_main_queue(), ^{
							[_delegate googleReaderUnreadsDidDownload:list];
						});
						//[_delegate googleReaderUnreadsDidDownload:list];
					}
				}
			}
			else {
				if (_delegate && [_delegate respondsToSelector:@selector(googleReaderDownloadFailed:)]) {
					dispatch_sync(dispatch_get_main_queue(), ^{
						[_delegate googleReaderDownloadFailed:nil];
					});
				}
			}
		}		
	});
	dispatch_release(queue);
	
#endif
}

- (void)getUnreadDidFinish:(ASIHTTPRequest *)request {
	if([request responseStatusCode] == 200) {
		NSData *body = [request responseData];
		id object = [NSJSONSerialization JSONObjectWithData:body
													options:_jsonReadingOptions
													  error:nil];
		if (object && [object isKindOfClass:[NSDictionary class]]) {
			NSArray *list = [object objectForKey:@"items"];
			//NSLog(@"all UnreadList download done(%d): %@", [list count], list);
			if (_delegate && [_delegate respondsToSelector:@selector(googleReaderUnreadsDidDownload:)]) {
				[_delegate googleReaderUnreadsDidDownload:list];
			}
		}
	}
	else {
		if (_delegate && [_delegate respondsToSelector:@selector(googleReaderDownloadFailed:)]) {
			[_delegate googleReaderDownloadFailed:nil];
		}
	}
}

- (void)getUnreadDidFail:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	if (error) {
		NSLog(@"getAllFeeds error: %@", [error description]);
		if (_delegate && [_delegate respondsToSelector:@selector(googleReaderDownloadFailed:)]) {
			[_delegate googleReaderDownloadFailed:error];
		}
	}
}

- (void)getStaredList {
	if (self.auth == nil) {
		return;
	}
	
#if MAIN_ASYNC
	
	NSString * timestamp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
	NSString * url = [NSString stringWithFormat:@"reader/api/0/stream/contents/user/-/state/com.google/starred?ck=%@&n=%d&client=%@", timestamp, [self maxSyncNum], CLIENT];

	ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[self googleURLExceptScheme:url]];
	[request setRequestMethod:@"GET"];
	[request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"GoogleLogin auth=%@", [self auth]]];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(getStaredDidFinish:)];
	[request setDidFailSelector:@selector(getStaredDidFail:)];
	
	self.mainRequest = request;
	
	[request startAsynchronous];
	
#else
	
	dispatch_queue_t queue = dispatch_queue_create(DISPATCH_FEED_NAME, NULL);
	dispatch_async(queue, ^{
		NSString * timestamp = [NSString stringWithFormat:@"%d", (long)[[NSDate date] timeIntervalSince1970]];
		NSString * url = [NSString stringWithFormat:@"reader/api/0/stream/contents/user/-/state/com.google/starred?ck=%@&n=%d&client=%@", timestamp, [self maxSyncNum], CLIENT];
		
		ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[self googleURLExceptScheme:url]];
		[request setRequestMethod:@"GET"];
		[request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"GoogleLogin auth=%@", [self auth]]];
		
		[request startSynchronous];
		
		NSError *error = [request error];
		if (error) {
			NSLog(@"getStaredList error: %@", [error description]);
			if (_delegate && [_delegate respondsToSelector:@selector(googleReaderDownloadFailed:)]) {
				dispatch_sync(dispatch_get_main_queue(), ^{
					[_delegate googleReaderDownloadFailed:error];
				});
			}
		} else {
			if([request responseStatusCode] == 200) {
				NSData *body = [request responseData];
				id object = [NSJSONSerialization JSONObjectWithData:body
															options:_jsonReadingOptions
															  error:nil];
				if (object && [object isKindOfClass:[NSDictionary class]]) {
					NSArray *list = [object objectForKey:@"items"];
					//NSLog(@"all StaredList download done(%d): %@", [list count], list);
					if (_delegate && [_delegate respondsToSelector:@selector(googleReaderStaredDidDownload:)]) {
						dispatch_sync(dispatch_get_main_queue(), ^{
							[_delegate googleReaderStaredDidDownload:list];
						});
						//[_delegate googleReaderStaredDidDownload:list];
					}
				}
			}
			else {
				if (_delegate && [_delegate respondsToSelector:@selector(googleReaderDownloadFailed:)]) {
					dispatch_sync(dispatch_get_main_queue(), ^{
						[_delegate googleReaderDownloadFailed:nil];
					});
				}
			}
		}
		
	});
	dispatch_release(queue);
	
#endif
}

- (void)getStaredDidFinish:(ASIHTTPRequest *)request {
	if([request responseStatusCode] == 200) {
		NSData *body = [request responseData];
		id object = [NSJSONSerialization JSONObjectWithData:body
													options:_jsonReadingOptions
													  error:nil];
		if (object && [object isKindOfClass:[NSDictionary class]]) {
			NSArray *list = [object objectForKey:@"items"];
			//NSLog(@"all StaredList download done(%d): %@", [list count], list);
			if (_delegate && [_delegate respondsToSelector:@selector(googleReaderStaredDidDownload:)]) {
				[_delegate googleReaderStaredDidDownload:list];
			}
		}
	}
	else {
		if (_delegate && [_delegate respondsToSelector:@selector(googleReaderDownloadFailed:)]) {
			[_delegate googleReaderDownloadFailed:nil];
		}
	}
}

- (void)getStaredDidFail:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	if (error) {
		NSLog(@"getStaredList error: %@", [error description]);
		if (_delegate && [_delegate respondsToSelector:@selector(googleReaderDownloadFailed:)]) {
			[_delegate googleReaderDownloadFailed:error];
		}
	}
}

- (void)getAllFeeds {
	if (self.auth == nil) {
		return;
	}
	
	dispatch_queue_t queue = dispatch_queue_create(DISPATCH_FEED_NAME, NULL);
	dispatch_async(queue, ^{
		NSString * timestamp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
		NSString * url = [NSString stringWithFormat:@"reader/api/0/stream/contents/user/-/state/com.google/reading-list?ot=%@&r=n&ck=%@&n=%d&client=%@", [self lastUpdateTime], timestamp, [self maxSyncNum], CLIENT];
		
		ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[self googleURLExceptScheme:url]];
		[request setRequestMethod:@"GET"];
		[request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"GoogleLogin auth=%@", [self auth]]];
		
		[request startSynchronous];
		
		NSError *error = [request error];
		if (error) {
			NSLog(@"getAllFeeds error: %@", [error description]);
			if (_delegate && [_delegate respondsToSelector:@selector(googleReaderDownloadFailed:)]) {
				dispatch_sync(dispatch_get_main_queue(), ^{
					[_delegate googleReaderDownloadFailed:error];
				});
			}
		} else {
			if([request responseStatusCode] == 200) {
				NSData *body = [request responseData];
				id object = [NSJSONSerialization JSONObjectWithData:body
															options:_jsonReadingOptions
															  error:nil];
				if (object && [object isKindOfClass:[NSDictionary class]]) {
					NSArray *list = [object objectForKey:@"items"];
					//NSLog(@"all AllFeeds download done(%d): %@", [list count], list);
					if (_delegate && [_delegate respondsToSelector:@selector(googleReaderAllFeedsDidDownload:)]) {
						dispatch_sync(dispatch_get_main_queue(), ^{
							[_delegate googleReaderAllFeedsDidDownload:list];
						});
						//[_delegate googleReaderAllFeedsDidDownload:list];
					}
				}
			}
			else {
				if (_delegate && [_delegate respondsToSelector:@selector(googleReaderDownloadFailed:)]) {
					dispatch_sync(dispatch_get_main_queue(), ^{
						[_delegate googleReaderDownloadFailed:nil];
					});
				}
			}
		}		
	});
}

- (void)getGoogleRecommendItems {
	
}

- (void)getGoogleRecommendSources {

}

- (void)getGoogleRecommendSourcesByFeedURL:(NSString *)feedURL max:(NSUInteger)maxNumber {
	if (self.auth == nil || feedURL == nil) {
		return;
	}
	
	dispatch_queue_t queue = dispatch_queue_create(DISPATCH_FEED_NAME, NULL);
	dispatch_async(queue, ^{
		NSString * timestamp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
		
		NSString * url = [NSString stringWithFormat:@"reader/api/0/related/list?n=%d&s=%@&output=json&ck=%@&client=%@", maxNumber,
						  [feedURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], timestamp, CLIENT];
		
		ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[self googleURLExceptScheme:url]];
		[request setRequestMethod:@"GET"];
		[request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"GoogleLogin auth=%@", [self auth]]];
		
		[request startSynchronous];
		
		NSError *error = [request error];
		if (error) {
			NSLog(@"get related error: %@ (%@)", [error description], feedURL);
		} else {
			if([request responseStatusCode] == 200) {
				NSData *body = [request responseData];
				id object = [NSJSONSerialization JSONObjectWithData:body
															options:_jsonReadingOptions
															  error:nil];
				if (object && [object isKindOfClass:[NSDictionary class]]) {
					NSLog(@"get related: %@", object);
				}
			}
		}
		
	});
}

- (void)getGoogleRecommendSourcesByFeedURL:(NSString *)feedURL {
	[self getGoogleRecommendSourcesByFeedURL:feedURL max:10];	
}

- (void)getFelaurRecommendSources {
	
}

- (void)getSubscriptionList {
	if (self.auth == nil) {
		return;
	}
	
#if MAIN_ASYNC
	
	NSString * url = [NSString stringWithFormat:@"reader/api/0/subscription/list?output=json&client=%@", CLIENT];
	
	ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[self googleURLExceptScheme:url]];
	[request setRequestMethod:@"GET"];
	[request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"GoogleLogin auth=%@", [self auth]]];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(getSubscriptionDidFinish:)];
	[request setDidFailSelector:@selector(getSubscriptionDidFail:)];
	
	self.mainRequest = request;
	
	[request startAsynchronous];
	
#else
	
	dispatch_queue_t queue = dispatch_queue_create(DISPATCH_FEED_NAME, NULL);
	dispatch_async(queue, ^{
		NSString * url = [NSString stringWithFormat:@"reader/api/0/subscription/list?output=json&client=%@", CLIENT];
		
		ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[self googleURLExceptScheme:url]];
		[request setRequestMethod:@"GET"];
		[request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"GoogleLogin auth=%@", [self auth]]];
		
		[request startSynchronous];
		
		NSError *error = [request error];
		if (error) {
			NSLog(@"getSubscriptionList error: %@", [error description]);
			if (_delegate && [_delegate respondsToSelector:@selector(googleReaderDownloadFailed:)]) {
				dispatch_sync(dispatch_get_main_queue(), ^{
					[_delegate googleReaderDownloadFailed:error];
				});
			}
		} else {
			if([request responseStatusCode] == 200) {
				NSData *body = [request responseData];
				id object = [NSJSONSerialization JSONObjectWithData:body
															options:_jsonReadingOptions
															  error:nil];
				if (object && [object isKindOfClass:[NSDictionary class]]) {
					NSArray *subscriptions = [object objectForKey:@"subscriptions"];
					//NSLog(@"all subscriptions download done: %@", subscriptions);
					
					if (_delegate && [_delegate respondsToSelector:@selector(googleReaderAllSubscriptionsDidDownload:)] ) {
						
						dispatch_sync(dispatch_get_main_queue(), ^{
							[_delegate googleReaderAllSubscriptionsDidDownload:subscriptions];
						});
						//[_delegate googleReaderAllSubscriptionsDidDownload:subscriptions];
					}
				}
			}
			else {
				if (_delegate && [_delegate respondsToSelector:@selector(googleReaderDownloadFailed:)]) {
					dispatch_sync(dispatch_get_main_queue(), ^{
						[_delegate googleReaderDownloadFailed:nil];
					});
				}
			}
		}		
	});
	dispatch_release(queue);
	
#endif
	
}

- (void)getSubscriptionDidFinish:(ASIHTTPRequest *)request {
	if([request responseStatusCode] == 200) {
		NSData *body = [request responseData];
		id object = [NSJSONSerialization JSONObjectWithData:body
													options:_jsonReadingOptions
													  error:nil];
		if (object && [object isKindOfClass:[NSDictionary class]]) {
			NSArray *subscriptions = [object objectForKey:@"subscriptions"];
			//NSLog(@"all subscriptions download done: %@", subscriptions);
			
			if (_delegate && [_delegate respondsToSelector:@selector(googleReaderAllSubscriptionsDidDownload:)] ) {
				[_delegate googleReaderAllSubscriptionsDidDownload:subscriptions];
			}
		}
	}
	else {
		if (_delegate && [_delegate respondsToSelector:@selector(googleReaderDownloadFailed:)]) {
			[_delegate googleReaderDownloadFailed:nil];
		}
	}
}

- (void)getSubscriptionDidFail:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	if (error) {
		NSLog(@"getSubscriptionList error: %@", [error description]);
		if (_delegate && [_delegate respondsToSelector:@selector(googleReaderDownloadFailed:)]) {
			[_delegate googleReaderDownloadFailed:error];
		}
	}
}

- (void)addRemoveStarAtFeedID:(NSString *)feedID forFeed:(NSString *)feedURL isStar:(BOOL)add {
	if (self.auth == nil || self.token == nil || feedURL == nil || feedID == nil) {
		return;
	}
	
	NSLog(@"start addRemoveStar: %@ / %@", feedID, feedURL);
	
	dispatch_queue_t queue = dispatch_queue_create(DISPATCH_FEED_MARK, NULL);
	dispatch_async(queue, ^{
		NSString *url = [NSString stringWithFormat:@"reader/api/0/edit-tag?client=%@", CLIENT];
		
		ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[self googleURLExceptScheme:url]];
		[request setRequestMethod:@"POST"];
		[request setPostValue:@"edit-tags" forKey:@"ac"];
		
		if (add) {
			[request setPostValue:@"user/-/state/com.google/starred" forKey:@"a"];
		} else {
			[request setPostValue:@"user/-/state/com.google/starred" forKey:@"r"];
		}
		
		[request setPostValue:@"true" forKey:@"async"];
		NSString *newFeedURL = feedURL;
		if ([feedURL hasPrefix:@"feed/"] == NO) {
			newFeedURL = [@"feed/" stringByAppendingString:feedURL];
		}
		[request setPostValue:newFeedURL forKey:@"s"];
		[request setPostValue:feedID forKey:@"i"];
		[request setPostValue:[self token] forKey:@"T"];
		[request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"GoogleLogin auth=%@", [self auth]]];
		
		[request startSynchronous];
		
		NSError *error = [request error];
		if (error) {
			NSLog(@"addRemoveStar error: %@ (%@)", [error description], feedURL);
		} else {
			//NSLog(@"addRemoveStar return: %@", [request responseString]);
			if([request responseStatusCode] == 200) {
				if ([[request responseString] isEqualToString:@"OK"]) {
					NSLog(@"addRemoveStar Success");
				} else {
					NSLog(@"addRemoveStar Failed");
				}
			}
		}
		
	});
}

- (void)addStarAtFeedID:(NSString *)feedID forFeed:(NSString *)feedURL {
	[self addRemoveStarAtFeedID:feedID forFeed:feedURL isStar:YES];
}

- (void)removeStarAtFeedID:(NSString *)feedID forFeed:(NSString *)feedURL {
	[self addRemoveStarAtFeedID:feedID forFeed:feedURL isStar:NO];
}

- (void)markReadUnreadAtFeedID:(NSString *)feedID forFeed:(NSString *)feedURL isRead:(BOOL)markRead {
	if (self.auth == nil || self.token == nil || feedURL == nil || feedID == nil) {
		return;
	}
	
	NSLog(@"start markRead: %@ / %@", feedID, feedURL);
	
	dispatch_queue_t queue = dispatch_queue_create(DISPATCH_FEED_MARK, NULL);
	dispatch_async(queue, ^{
		NSString *url = [NSString stringWithFormat:@"reader/api/0/edit-tag?client=%@", CLIENT];
		
		ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[self googleURLExceptScheme:url]];
		[request setRequestMethod:@"POST"];
		[request setPostValue:@"edit-tags" forKey:@"ac"];
		
		if (markRead) {
			[request setPostValue:@"user/-/state/com.google/read" forKey:@"a"];
			[request setPostValue:@"user/-/state/com.google/tracking-kept-unread" forKey:@"r"];
		} else {
			[request setPostValue:@"user/-/state/com.google/read" forKey:@"r"];
			[request setPostValue:@"user/-/state/com.google/tracking-kept-unread" forKey:@"a"];
		}
		
		[request setPostValue:@"true" forKey:@"async"];
		NSString *newFeedURL = feedURL;
		if ([feedURL hasPrefix:@"feed/"] == NO) {
			newFeedURL = [@"feed/" stringByAppendingString:feedURL];
		}
		[request setPostValue:newFeedURL forKey:@"s"];
		[request setPostValue:feedID forKey:@"i"];
		[request setPostValue:[self token] forKey:@"T"];
		[request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"GoogleLogin auth=%@", [self auth]]];
		
		[request startSynchronous];
		
		NSError *error = [request error];
		if (error) {
			NSLog(@"markRead error: %@ (%@)", [error description], feedURL);
		} else {
			NSLog(@"markRead return: %@", [request responseString]);
			if([request responseStatusCode] == 200) {
				if ([[request responseString] isEqualToString:@"OK"]) {
					NSLog(@"markRead Success");
				} else {
					NSLog(@"markRead Failed");
				}
			}
		}
		
	});
}

- (void)markReadAtFeedID:(NSString *)feedID forFeed:(NSString *)feedURL {
	[self markReadUnreadAtFeedID:feedID forFeed:feedURL isRead:YES];
}

- (void)markUnreadAtFeedID:(NSString *)feedID forFeed:(NSString *)feedURL {
	[self markReadUnreadAtFeedID:feedID forFeed:feedURL isRead:NO];
}

- (void)renameFolder {
	
}

@end
