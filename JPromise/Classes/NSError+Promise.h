//
//  NSError+Promise.h
//  
//
//  Created by jams on 2020/1/2.
//  Copyright © 2020 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString *const kJPromiseErrorReason;
UIKIT_EXTERN NSString *const kJPromiseErrorType;
UIKIT_EXTERN NSString *const kJPromiseErrorTag; //用于标记error来源

typedef NS_ENUM(NSUInteger, CCPromiseErrorType){
    JPromiseErrorTypeReject = 1,
    JPromiseErrorTypeCancel,
};

@interface NSError (Promise)

+ (instancetype)errorWithReason:(nullable NSString *)reason;

+ (instancetype)errorWithCode:(NSInteger)code errorReason:(nullable NSString *)reason;

+ (instancetype)errorWithReason:(NSString *)reason errorTag:(NSString *)errorTag;

+ (instancetype)errorWithCode:(NSInteger)code errorReason:(nullable NSString *)reason errorTag:(NSString *)errorTag;

+ (instancetype)errorWithType:(CCPromiseErrorType)errorType;

+ (instancetype)errorWithType:(CCPromiseErrorType)errorType reason:(nullable NSString *)reason;

+ (instancetype)errorWithType:(CCPromiseErrorType)errorType code:(NSInteger)code reason:(NSString *)reason;

- (NSString *)errorReason;

- (CCPromiseErrorType)errorType;

- (NSInteger)errorCode;

- (NSString *)errorTag;

@end

NS_ASSUME_NONNULL_END
