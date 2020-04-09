//
//  CCPromise+All.m
//  CCPlayLiveKit
//
//  Created by jams on 2020/1/2.
//  Copyright © 2020 netease. All rights reserved.
//

#import "JPromise+All.h"
#import "JPromiseInternal.h"

@implementation JPromise (All)

+ (instancetype)j_all:(NSArray *)promises {
    NSParameterAssert(promises);
    if (promises.count == 0) {
        return [JPromise promiseWithValue:@[]];
    }
    
    NSMutableArray *allPromises = [promises mutableCopy];
    return [JPromise promiseWithBlock:^(JPromiseFulfillBlock  _Nonnull fulfill, JPromiseRejectBlock  _Nonnull reject) {
        for (NSUInteger i = 0; i < allPromises.count; i ++) { //检查类型
            id promise = allPromises[i];
            if ([promise isKindOfClass:[JPromise class]]) {
                continue;
            } else if ([promises isKindOfClass:[NSError class]]) {
                reject(promise);
                return;
            } else {
                [allPromises replaceObjectAtIndex:i withObject:[JPromise promiseWithValue:promise]];
            }
        }
        
        for (JPromise *promise in allPromises) {
            [promise observeWithFulFill:^(id  _Nullable value) {
                for (JPromise *promise in allPromises) { //保证所有promise都已经完成
                    if (!promise.isFulfilled) {
                        return;
                    }
                }
                fulfill([allPromises valueForKey:NSStringFromSelector(@selector(value))]);
            } reject:^(NSError * _Nonnull error) {
                reject(error);
            }];
        }
        
    }];
}

@end
