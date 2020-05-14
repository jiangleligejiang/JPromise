//
//  JPromise+Catch.m
//  
//
//  Created by jams on 2020/4/7.
//  Copyright © 2020 netease. All rights reserved.
//

#import "JPromise+Catch.h"
#import "JPromiseInternal.h"
#import "NSError+Promise.h"

@implementation JPromise (Catch)

- (JPromise *(^)(JPromiseCatchBlock _Nonnull))j_catch {
    __weak typeof(self) weakSelf = self;
    return ^(JPromiseCatchBlock catchBlock) {
        return [weakSelf j_catch:catchBlock];
    };
}

- (JPromise *)j_catch:(JPromiseCatchBlock)catchBlock {
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
        resolver(value);
    } reject:^(NSError * _Nonnull error) {
        if (error.errorType != JPromiseErrorTypeCancel && catchBlock) {
            catchBlock(error);
        }
        resolver(error);
    }];
    return promise;
}

@end
