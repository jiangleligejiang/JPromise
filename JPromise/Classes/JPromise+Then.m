//
//  JPromise+Then.m
//  
//
//  Created by jams on 2020/4/7.
//  Copyright © 2020 netease. All rights reserved.
//

#import "JPromise+Then.h"
#import "JPromiseInternal.h"
#import "JPromise+Internal.h"

@implementation JPromise (Then)

- (JPromise * _Nonnull (^)(id _Nonnull))j_then {
    __weak typeof(self) weakSelf = self;
    return ^(JPromiseThenBlock thenBlock) {
        return [weakSelf j_then:thenBlock];
    };
}

- (JPromise * _Nonnull (^)(id _Nonnull))j_thenAsync {
    __weak typeof(self) weakSelf = self;
    return ^(JPromiseThenBlock thenBlock) {
        return [weakSelf j_thenAsync:thenBlock];
    };
}

- (JPromise * _Nonnull (^)(dispatch_queue_t _Nullable, id _Nonnull))j_thenOn {
    __weak typeof(self) weakSelf = self;
    return ^(dispatch_queue_t queue, JPromiseThenBlock thenBlock) {
        return [weakSelf onQueue:queue j_then:thenBlock];
    };
}

- (JPromise *)j_then:(JPromiseThenBlock)thenBlock {
    return [self onQueue:dispatch_get_main_queue() j_then:thenBlock];
}

- (JPromise *)j_thenAsync:(JPromiseThenBlock)thenBlock {
    return [self onQueue:JPromise.defaultAsyncQueue j_then:thenBlock];
}

- (JPromise *)onQueue:(dispatch_queue_t)queue j_then:(JPromiseThenBlock)thenBlock {
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
    
    __weak typeof(self) weakSelf = self;
    [self observeWithFulFill:^(id  _Nullable value) {
        [weakSelf callBlock:thenBlock withValue:value withQueue:queue completionBlock:^(id _Nullable result) {
            if ([NSThread isMainThread]) {
                resolver(result);
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resolver(result);
                });
            }
        }];
    } reject:^(NSError * _Nonnull error) {
        [promise reject:error];
    }];
    
    return promise;
}

@end
