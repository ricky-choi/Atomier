//
//  OfflineHelper.m
//  Atomier
//
//  Created by Ricky on 12. 9. 7..
//  Copyright (c) 2012년 Appcid. All rights reserved.
//

#import "OfflineHelper.h"

@implementation OfflineHelper

+ (id)sharedInstance {
    static OfflineHelper *sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[OfflineHelper alloc] init];
	});
	return sharedInstance;
}

@end
