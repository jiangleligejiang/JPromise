//
//  CCPromiseInternal.h
//  
//
//  Created by jams on 2020/1/2.
//  Copyright © 2020 netease. All rights reserved.
//

#import "JPromise.h"

typedef NS_ENUM(NSUInteger, CCPromiseState) {
    JPromiseStatePending,
    JPromiseStateFulfilled,
    JPromiseStateRejected,
};

NS_ASSUME_NONNULL_BEGIN

@interface JPromise () {
    __weak id _Nullable _target; //持有调用者弱引用，当调用对象release后，会自动停止相关流程
}

- (instancetype)initWithTarget:(id)target;

- (void)fulfill:(_Nullable id)value;

- (void)reject:(NSError *)error;

- (void)observeWithFulFill:(JPromiseFulfillBlock)onFulfill reject:(JPromiseRejectBlock)onReject;

@end

NS_ASSUME_NONNULL_END
