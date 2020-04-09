//
//  NSError+Promise.m
//  CCPlayLiveKit
//
//  Created by jams on 2020/1/2.
//  Copyright © 2020 netease. All rights reserved.
//

#import "NSError+Promise.h"

NSString *const kCCPromiseErrorReason = @"kCCPromiseErrorReason";
NSString *const kCCPromiseErrorType = @"kCCPromiseErrorType";

@implementation NSError (Promise)

+ (instancetype)errorWithType:(CCPromiseErrorType)errorType {
    return [self errorWithType:errorType reason:nil];
}

+ (instancetype)errorWithType:(CCPromiseErrorType)errorType reason:(NSString *)reason {
    return [self errorWithType:errorType code:-1 reason:reason];
}

+ (instancetype)errorWithType:(CCPromiseErrorType)errorType code:(NSInteger)code reason:(NSString *)reason {
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [info setObject:reason forKey:kCCPromiseErrorReason];
    [info setObject:@(errorType) forKey:kCCPromiseErrorType];
    return [NSError errorWithDomain:NSCocoaErrorDomain code:code userInfo:[info copy]];
}

+ (instancetype)errorWithReason:(NSString *)reason {
    return [self errorWithCode:-1 errorReason:reason];
}

+ (instancetype)errorWithCode:(NSInteger)code errorReason:(NSString *)reason {
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [info setObject:reason forKey:kCCPromiseErrorReason];
    return [NSError errorWithDomain:NSCocoaErrorDomain code:code userInfo:[info copy]];
}

- (NSString *)errorReason {
    if (self.userInfo.count > 0) {
        return [self.userInfo objectForKey:kCCPromiseErrorReason];
    }
    return nil;
}

- (CCPromiseErrorType)errorType {
    if (self.userInfo.count > 0) {
        NSNumber *value = [self.userInfo objectForKey:kCCPromiseErrorType];
        if ([value isKindOfClass:[NSNumber class]]) {
            return value.integerValue;
        }
    }
    return CCPromiseErrorTypeReject;
}

- (NSInteger)errorCode {
    return self.code;
}

@end
