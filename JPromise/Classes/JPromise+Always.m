//
//  CCPromise+Always.m
//  CCPlayLiveKit
//
//  Created by jams on 2020/4/7.
//  Copyright © 2020 netease. All rights reserved.
//

#import "JPromise+Always.h"
#import "JPromiseInternal.h"
#import "NSError+Promise.h"

@implementation JPromise (Always)

- (JPromise *)j_always:(JPromiseAlwaysBlock)alwaysBlock {
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
        if (alwaysBlock) {
            alwaysBlock();
        }
        resolver(value);
    } reject:^(NSError * _Nonnull error) {
       if (error.errorType != CCPromiseErrorTypeCancel && alwaysBlock) {
           alwaysBlock();
       }
       resolver(error);
    }];
   return promise;
}

- (JPromise * _Nonnull (^)(JPromiseAlwaysBlock _Nonnull))j_always {
    __weak typeof(self) weakSelf = self;
    return ^(JPromiseAlwaysBlock alwaysBlock) {
        return [weakSelf j_always:alwaysBlock];
    };
}

@end
