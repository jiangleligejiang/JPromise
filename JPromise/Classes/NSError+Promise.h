//
//  NSError+Promise.h
//  CCPlayLiveKit
//
//  Created by jams on 2020/1/2.
//  Copyright © 2020 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString *const kCCPromiseErrorReason;
UIKIT_EXTERN NSString *const kCCPromiseErrorType;

typedef NS_ENUM(NSUInteger, CCPromiseErrorType){
    CCPromiseErrorTypeReject = 1,
    CCPromiseErrorTypeCancel,
};

@interface NSError (Promise)

+ (instancetype)errorWithReason:(nullable NSString *)reason;

+ (instancetype)errorWithCode:(NSInteger)code errorReason:(nullable NSString *)reason;

+ (instancetype)errorWithType:(CCPromiseErrorType)errorType;

+ (instancetype)errorWithType:(CCPromiseErrorType)errorType reason:(nullable NSString *)reason;

+ (instancetype)errorWithType:(CCPromiseErrorType)errorType code:(NSInteger)code reason:(NSString *)reason;

- (nullable NSString *)errorReason;

- (CCPromiseErrorType)errorType;

- (NSInteger)errorCode;

@end

NS_ASSUME_NONNULL_END
