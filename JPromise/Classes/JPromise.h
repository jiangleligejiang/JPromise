//
//  CCPromise.h
//  CCPlayLiveKit
//
//  Created by jams on 2020/1/2.
//  Copyright © 2020 netease. All rights reserved.
//  基于Promises(https://github.com/google/promises) 和 PromiseKit(https://github.com/mxcl/PromiseKit) 的实现
//  主要用于流程复杂的业务，可以通过`j_then`操作将业务串联起来，若流程中出错，则可以通过`j_catch`获取到错误，并将终止流程，若流程被自动取消，则可以通过`cc_cancel`获取到通知
//  具体使用可参考：JPromiseExample


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class JPromise;

typedef void (^JPromiseFulfillBlock)(id _Nullable value);
typedef void(^JPromiseRejectBlock)(NSError *error);
typedef void(^CCPromiseBlock)(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject);

@interface JPromise : NSObject

+ (instancetype)promiseWithBlock:(CCPromiseBlock)promiseBlock;

/// 创建Promise方法
/// @param target 用于与外部调用者生命周期的绑定，设置target为调用者self，内部会存储其弱引用，则当调用者（比如ViewController）被释放，则promise流程会被自动取消，并通过`cc_cancel`通知
+ (instancetype)promiseWithBlock:(CCPromiseBlock)promiseBlock target:(_Nullable id)target;

+ (instancetype)promiseWithValue:(_Nullable id)value;

+ (instancetype)promiseWithValue:(_Nullable id)value target:(_Nullable id)target;

/// 默认异步线程队列
+ (dispatch_queue_t)defaultAsyncQueue;

/// 当前Promise的状态
- (BOOL)isFulfilled;

- (BOOL)isRejected;

- (BOOL)isPending;

@end

NS_ASSUME_NONNULL_END
