//
//  JPromise.m
//
//  Created by jams on 2020/1/2.
//  Copyright © 2020 netease. All rights reserved.
//

#import "JPromise.h"
#import "JPromiseInternal.h"
#import "NSError+Promise.h"
#import "JPromise+Internal.h"

NSString *const kCCPromiseContinualTarget = @"kCCPromiseContinualTarget"; //内部默认的target

typedef void(^JPromiseObserver)(CCPromiseState state, id _Nullable resolution);

static dispatch_queue_t j_promise_default_async_queue;

@implementation JPromise {
    CCPromiseState _state;
    id _Nullable _value;
    NSError *_Nullable _error;
    NSMutableSet *_Nullable _pendingObjects;
    NSMutableArray<JPromiseObserver> *_observers;
}

#pragma mark - default queue

+ (dispatch_queue_t)defaultAsyncQueue {
    return j_promise_default_async_queue;
}

#pragma mark - init

+ (void)initialize {
    if (self == [JPromise class]) {
        j_promise_default_async_queue = dispatch_get_global_queue(0, 0);
    }
}

- (void)dealloc {
    _pendingObjects = nil;
    _observers = nil;
}

+ (instancetype)promiseWithBlock:(JPromiseBlock)promiseBlock {
    return [self promiseWithBlock:promiseBlock target:kCCPromiseContinualTarget];
}

+ (instancetype)promiseWithBlock:(JPromiseBlock)promiseBlock target:(id)target {
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
        _state = JPromiseStatePending;
    }
    return self;
}

- (instancetype)initWithTarget:(id)target {
    if (self = [super init]) {
        _state = JPromiseStatePending;
        _target = target;
    }
    return self;
}

#pragma mark - state

- (BOOL)isPending {
    return _state == JPromiseStatePending;
}

- (BOOL)isFulfilled {
    return _state == JPromiseStateFulfilled;
}

- (BOOL)isRejected {
    return _state == JPromiseStateRejected;
}

#pragma mark - fulfill & reject

- (void)fulfill:(id)value {
    if (!_target) {
        [self reject:[NSError errorWithType:JPromiseErrorTypeCancel]];
        return;
    }
    
    if ([value isKindOfClass:[NSError class]]) {
        [self reject:(NSError *)value];
    } else {
        if (_state == JPromiseStatePending) {
            _state = JPromiseStateFulfilled;
            _value = value;
            _pendingObjects = nil;
            for (JPromiseObserver observer in _observers) {
                observer(_state, _value);
            }
            _observers = nil;
        }
    }
}

- (void)reject:(NSError *)error {
    NSAssert([error isKindOfClass:[NSError class]], @"Invalid error type");
    if (_state == JPromiseStatePending) {
        _state = JPromiseStateRejected;
        _error = error;
        _pendingObjects = nil;
        for (JPromiseObserver observer in _observers) {
            observer(_state, _error);
        }
        _observers = nil;
    }
}

- (void)observeWithFulFill:(JPromiseFulfillBlock)onFulfill reject:(JPromiseRejectBlock)onReject {
    NSParameterAssert(onFulfill);
    NSParameterAssert(onReject);
    
    switch (_state) {
        case JPromiseStatePending:{
            if (!_observers) {
                _observers = [NSMutableArray array];
                [_observers addObject:^(CCPromiseState state, id _Nullable resolution){
                    switch (state) {
                        case JPromiseStatePending:
                            break;
                        case JPromiseStateFulfilled:
                            onFulfill(resolution);
                            break;
                        case JPromiseStateRejected:
                            onReject(resolution);
                            break;
                    }
                }];
            }
            break;
        }
            
        case JPromiseStateFulfilled: {
            onFulfill(_value);
            break;
        }
        
        case JPromiseStateRejected: {
            onReject(_error);
            break;
        }
    }
}

#pragma mark - getter

- (NSMutableSet *__nullable)pendingObjects {
    if (_state == JPromiseStatePending) {
      if (!_pendingObjects) {
        _pendingObjects = [[NSMutableSet alloc] init];
      }
    }
    return _pendingObjects;
}

@end
