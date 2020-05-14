//
//  NSError+Promise.m
//  
//
//  Created by jams on 2020/1/2.
//  Copyright © 2020 netease. All rights reserved.
//

#import "NSError+Promise.h"

NSString *const kJPromiseErrorReason = @"kJPromiseErrorReason";
NSString *const kJPromiseErrorType = @"kJPromiseErrorType";
NSString *const kJPromiseErrorTag = @"kJPromiseErrorTag";

@implementation NSError (Promise)

+ (instancetype)errorWithType:(CCPromiseErrorType)errorType {
    return [self errorWithType:errorType reason:nil];
}

+ (instancetype)errorWithType:(CCPromiseErrorType)errorType reason:(NSString *)reason {
    return [self errorWithType:errorType code:-1 reason:reason];
}

+ (instancetype)errorWithType:(CCPromiseErrorType)errorType code:(NSInteger)code reason:(NSString *)reason {
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [info setObject:reason forKey:kJPromiseErrorReason];
    [info setObject:@(errorType) forKey:kJPromiseErrorType];
    return [NSError errorWithDomain:NSCocoaErrorDomain code:code userInfo:[info copy]];
}

+ (instancetype)errorWithReason:(NSString *)reason {
    return [self errorWithCode:-1 errorReason:reason];
}

+ (instancetype)errorWithCode:(NSInteger)code errorReason:(NSString *)reason {
    return [self errorWithCode:code errorReason:reason errorTag:@""];
}

+ (instancetype)errorWithReason:(NSString *)reason errorTag:(NSString *)errorTag {
    return [self errorWithCode:-1 errorReason:reason errorTag:errorTag];
}

+ (instancetype)errorWithCode:(NSInteger)code errorReason:(NSString *)reason errorTag:(NSString *)errorTag {
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    if (reason) {
        [info setObject:reason forKey:kJPromiseErrorReason];
    }
    if (errorTag && errorTag.length > 0) {
        [info setObject:errorTag forKey:kJPromiseErrorTag];
    }
    return [NSError errorWithDomain:NSCocoaErrorDomain code:code userInfo:[info copy]];
}

- (NSString *)errorReason {
    if (self.userInfo.count > 0) {
        return [self.userInfo objectForKey:kJPromiseErrorReason] ?: @"";
    }
    return @"";
}

- (CCPromiseErrorType)errorType {
    if (self.userInfo.count > 0) {
        NSNumber *value = [self.userInfo objectForKey:kJPromiseErrorType];
        if ([value isKindOfClass:[NSNumber class]]) {
            return value.integerValue;
        }
    }
    return JPromiseErrorTypeReject;
}

- (NSInteger)errorCode {
    return self.code;
}

- (NSString *)errorTag {
    if (self.userInfo.count > 0) {
        return [self.userInfo objectForKey:kJPromiseErrorTag] ?: @"";
    }
    return @"";
}

@end
