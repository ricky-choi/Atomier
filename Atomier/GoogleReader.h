//
//  GoogleReader.h
//  GoogleReader
//
//  Created by Choi Jaeyoung on 12/2/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASIHTTPRequest;

@protocol GoogleReaderDelegate <NSObject>

- (BOOL)isWWAN;

- (void)googleReaderAuthenticateSuccess;
- (void)googleReaderAuthenticateFailed:(id)info;

- (void)googleReaderRequestTokenFailed;

- (void)googleReaderAllSubscriptionsDidDownload:(NSArray *)allSubscriptions;
- (void)googleReaderUnreadsDidDownload:(NSArray *)allUnreads;
- (void)googleReaderStaredDidDownload:(NSArray *)allStareds;

- (void)googleReaderDownloadFailed:(NSError *)error;

@optional

- (void)googleReaderUnreadCountDidDownloadForLabel:(NSArray *)labelUnreadCounts forSubscription:(NSArray *)subscriptionUnreadCounts;
- (void)googleReaderAllFeedsDidDownload:(NSArray *)allFeeds;

@end

@protocol GoogleReaderSubscribeDelegate <NSObject>

@optional
- (void)googleReaderSubscribeNoResults;
- (void)googleReaderSubscribeDone;
- (void)googleReaderSubscribeFailed;
- (void)googleReaderStartSearch;
- (void)googleReaderSearchFailed;
- (void)googleReaderSearchDone:(NSDictionary *)searchData;

@end

@interface GoogleReader : NSObject

+ (id)sharedInstance;

@property (nonatomic, weak) id <GoogleReaderDelegate> delegate;
@property (nonatomic, weak) id <GoogleReaderSubscribeDelegate> subscribeDelegate;

@property (nonatomic, strong) ASIHTTPRequest *mainRequest;

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;

@property (nonatomic, strong) NSDate *lastUpdate;

@property (nonatomic, assign) NSJSONReadingOptions jsonReadingOptions;

- (BOOL)cookieExist;
- (void)requestSession;
- (void)requestToken;

- (void)getAuthSmart;
- (BOOL)isAuth;
- (BOOL)isToken;
- (void)deleteAuth;
- (void)deleteToken;
- (void)deleteIDInfo;

- (void)getUnreadList;
- (void)getUnreadCount;
- (void)getStaredList;
- (void)getSubscriptionList;
- (void)getAllFeeds;

- (void)getGoogleRecommendItems;
- (void)getGoogleRecommendSources;
- (void)getGoogleRecommendSourcesByFeedURL:(NSString *)feedURL;
- (void)getGoogleRecommendSourcesByFeedURL:(NSString *)feedURL max:(NSUInteger)maxNumber;
- (void)getFelaurRecommendSources;

- (void)searchKeyword:(NSString *)keyword;
- (void)searchKeyword:(NSString *)keyword start:(int)startPage;

- (void)cancelMainRequest;

- (void)quickSubscribeToRSSFeedURL:(NSString *)feedURL;
- (void)quickSubscribeToRSSFeedURL:(NSString *)feedURL moreSearch:(BOOL)more;
- (void)subscribeToRSSFeedURL:(NSString *)feedURL atCategory:(NSString *)categoryLabel;
- (void)subscribeToRSSFeedURL:(NSString *)feedURL atCategory:(NSString *)categoryLabel forNewFeedName:(NSString *)feedName;
- (void)unsubscribeToRSSFeedURL:(NSString *)feedURL;

- (void)renameRSSFeedURL:(NSString *)feedURL forNewFeedName:(NSString *)feedName;
- (void)editCategoryRSSFeedURL:(NSString *)feedURL toCategory:(NSString *)newCategory;
- (void)editCategoryRSSFeedURL:(NSString *)feedURL fromCategory:(NSString *)oldCategory toCategory:(NSString *)newCategory;
- (void)deleteRSSFeedURL:(NSString *)feedURL fromCategory:(NSString *)category;

- (void)addStarAtFeedID:(NSString *)feedID forFeed:(NSString *)feedURL;
- (void)removeStarAtFeedID:(NSString *)feedID forFeed:(NSString *)feedURL;

- (void)markReadAtFeedID:(NSString *)feedID forFeed:(NSString *)feedURL;
- (void)markUnreadAtFeedID:(NSString *)feedID forFeed:(NSString *)feedURL;

- (void)renameFolder;

@end
