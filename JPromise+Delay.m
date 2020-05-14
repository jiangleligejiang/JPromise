//
//  JPromise+Delay.m
//  JPromise
//
//  Created by jams on 2020/5/14.
//

#import "JPromise+Delay.h"
#import "JPromiseInternal.h"

@implementation JPromise (Delay)

- (instancetype)j_delay:(NSTimeInterval)interval {
    return [self onQueue:dispatch_get_main_queue() j_delay:interval];
}

- (instancetype)onQueue:(dispatch_queue_t)queue j_delay:(NSTimeInterval)interval {
    NSParameterAssert(queue);
    NSAssert(interval >= 0, @"delay time must greater than or equal to zero");
    
    JPromise *promise = [[JPromise alloc] initWithTarget:_target];
    
    __auto_type resolver = ^(id _Nullable value) {
        if ([value isKindOfClass:[JPromise class]]) {
            [(JPromise *)value observeWithFulFill:^(id  _Nullable value) {
                [promise fulfill:value];
            } reject:^(NSError * _Nonnull error) {
                [promise reject:error];
            }];
        } else {
            [promise fulfill:value];
        }
    };
    
    
    [self observeWithFulFill:^(id  _Nullable value) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), queue, ^{
            resolver(value);
        });
    } reject:^(NSError * _Nonnull error) {
        [promise reject:error];
    }];
    
    return promise;
}

- (JPromise * _Nonnull (^)(NSTimeInterval))j_delay {
    __weak typeof(self) weakSelf = self;
    return ^(NSTimeInterval interval) {
        return [weakSelf j_delay:interval];
    };
}

- (JPromise * _Nonnull (^)(dispatch_queue_t _Nonnull, NSTimeInterval))j_delayOn {
    __weak typeof(self) weakSelf = self;
    return ^(dispatch_queue_t queue, NSTimeInterval interval) {
        return [weakSelf onQueue:queue j_delay:interval];
    };
}


@end
