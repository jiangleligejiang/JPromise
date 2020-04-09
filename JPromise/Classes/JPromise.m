//
//  CCPromise.m
//  CCPlayLiveKit
//
//  Created by jams on 2020/1/2.
//  Copyright © 2020 netease. All rights reserved.
//

#import "JPromise.h"
#import "JPromiseInternal.h"
#import "NSError+Promise.h"
#import "JPromise+Internal.h"

NSString *const kCCPromiseContinualTarget = @"kCCPromiseContinualTarget"; //内部默认的target

typedef void(^CCPromiseObserver)(CCPromiseState state, id _Nullable resolution);

static dispatch_queue_t cc_promise_default_async_queue;

@implementation JPromise {
    CCPromiseState _state;
    id _Nullable _value;
    NSError *_Nullable _error;
    NSMutableSet *_Nullable _pendingObjects;
    NSMutableArray<CCPromiseObserver> *_observers;
}

#pragma mark - default queue

+ (dispatch_queue_t)defaultAsyncQueue {
    return cc_promise_default_async_queue;
}

#pragma mark - init

+ (void)initialize {
    if (self == [JPromise class]) {
        cc_promise_default_async_queue = dispatch_get_global_queue(0, 0);
    }
}

- (void)dealloc {
    _pendingObjects = nil;
    _observers = nil;
}

+ (instancetype)promiseWithBlock:(CCPromiseBlock)promiseBlock {
    return [self promiseWithBlock:promiseBlock target:kCCPromiseContinualTarget];
}

+ (instancetype)promiseWithBlock:(CCPromiseBlock)promiseBlock target:(id)target {
    JPromise *promise = [[JPromise alloc] initWithTarget:target];
    promiseBlock(
                ^(id _Nullable value) {
                    if ([value isKindOfClass:[JPromise class]]) {
                        [(JPromise *)value observeWithFulFill:^(id  _Nullable value) {
                            [promise fulfill:value];
                        } reject:^(NSError * _Nonnull error) {
                            [promise reject:error];
                        }];
                    } else {
                        [promise fulfill:value];
                    }
                },
                ^(NSError *error) {
                    [promise reject:error];
                }
                 );
    return promise;
}

+ (instancetype)promiseWithValue:(id)value {
    return [self promiseWithValue:value target:kCCPromiseContinualTarget];
}

+ (instancetype)promiseWithValue:(id)value target:(id)target {
    return [self promiseWithBlock:^(JPromiseFulfillBlock  _Nonnull fulfill, JPromiseRejectBlock  _Nonnull reject) {
        fulfill(value);
    } target:target];
}

- (instancetype)initWithPending {
    if (self = [super init]) {
        _state = CCPromiseStatePending;
    }
    return self;
}

- (instancetype)initWithTarget:(id)target {
    if (self = [super init]) {
        _state = CCPromiseStatePending;
        _target = target;
    }
    return self;
}

#pragma mark - state

- (BOOL)isPending {
    return _state == CCPromiseStatePending;
}

- (BOOL)isFulfilled {
    return _state == CCPromiseStateFulfilled;
}

- (BOOL)isRejected {
    return _state == CCPromiseStateRejected;
}

#pragma mark - fulfill & reject

- (void)fulfill:(id)value {
    if (!_target) {
        [self reject:[NSError errorWithType:CCPromiseErrorTypeCancel]];
        return;
    }
    
    if ([value isKindOfClass:[NSError class]]) {
        [self reject:(NSError *)value];
    } else {
        if (_state == CCPromiseStatePending) {
            _state = CCPromiseStateFulfilled;
            _value = value;
            _pendingObjects = nil;
            for (CCPromiseObserver observer in _observers) {
                observer(_state, _value);
            }
            _observers = nil;
        }
    }
}

- (void)reject:(NSError *)error {
    NSAssert([error isKindOfClass:[NSError class]], @"Invalid error type");
    if (_state == CCPromiseStatePending) {
        _state = CCPromiseStateRejected;
        _error = error;
        _pendingObjects = nil;
        for (CCPromiseObserver observer in _observers) {
            observer(_state, _error);
        }
        _observers = nil;
    }
}

- (void)observeWithFulFill:(JPromiseFulfillBlock)onFulfill reject:(JPromiseRejectBlock)onReject {
    NSParameterAssert(onFulfill);
    NSParameterAssert(onReject);
    
    switch (_state) {
        case CCPromiseStatePending:{
            if (!_observers) {
                _observers = [NSMutableArray array];
                [_observers addObject:^(CCPromiseState state, id _Nullable resolution){
                    switch (state) {
                        case CCPromiseStatePending:
                            break;
                        case CCPromiseStateFulfilled:
                            onFulfill(resolution);
                            break;
                        case CCPromiseStateRejected:
                            onReject(resolution);
                            break;
                    }
                }];
            }
            break;
        }
            
        case CCPromiseStateFulfilled: {
            onFulfill(_value);
            break;
        }
        
        case CCPromiseStateRejected: {
            onReject(_error);
            break;
        }
    }
}

#pragma mark - getter

- (NSMutableSet *__nullable)pendingObjects {
    if (_state == CCPromiseStatePending) {
      if (!_pendingObjects) {
        _pendingObjects = [[NSMutableSet alloc] init];
      }
    }
    return _pendingObjects;
}

@end
