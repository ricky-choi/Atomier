//
//  OfflineHelper.h
//  Atomier
//
//  Created by Ricky on 12. 9. 7..
//  Copyright (c) 2012년 Appcid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h> // for MD5 hash

@interface OfflineHelper : NSObject

+ (id)sharedInstance;

@end
