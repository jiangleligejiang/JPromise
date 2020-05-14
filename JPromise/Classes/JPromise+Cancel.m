//
//  JPromise+Cancel.m
//  
//
//  Created by jams on 2020/4/7.
//  Copyright © 2020 netease. All rights reserved.
//

#import "JPromise+Cancel.h"
#import "JPromiseInternal.h"
#import "NSError+Promise.h"

@implementation JPromise (Cancel)

- (JPromise * _Nonnull (^)(JPromiseCancelBlock _Nonnull))cc_cancel {
    __weak typeof(self) weakSelf = self;
    return ^(JPromiseCancelBlock cancelBlock) {
        return [weakSelf cc_cancel:cancelBlock];
    };
}

- (JPromise *)cc_cancel:(JPromiseCancelBlock)cancelBlock {
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
        if (error.errorType == JPromiseErrorTypeCancel && cancelBlock) {
            cancelBlock();
        }
        resolver(error);
    }];
    return promise;
}

@end
