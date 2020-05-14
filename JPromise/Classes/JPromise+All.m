//
//  JPromise+All.m
//
//  Created by jams on 2020/1/2.
//  Copyright © 2020 netease. All rights reserved.
//

#import "JPromise+All.h"
#import "JPromiseInternal.h"

@implementation JPromise (All)

+ (instancetype)j_all:(NSArray *)promises {
    return [self j_all:promises isContinue:NO];
}

+ (instancetype)j_all:(NSArray *)promises isContinue:(BOOL)isContinue {
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
        
        __block NSError *promiseError = nil;
        for (JPromise *promise in allPromises) {
            [promise observeWithFulFill:^(id  _Nullable value) {
                if (isContinue && promiseError) {
                    for (JPromise *promise in allPromises) { //保证所有promise都已经被处理
                        if (promise.isPending) {
                            return;
                        }
                    }
                    reject(promiseError);
                } else {
                    for (JPromise *promise in allPromises) { //保证所有promise都已经完成
                        if (!promise.isFulfilled) {
                            return;
                        }
                    }
                    fulfill([allPromises valueForKey:NSStringFromSelector(@selector(value))]);
                }
            } reject:^(NSError * _Nonnull error) {
                promiseError = error;
                if (isContinue) {
                    for (JPromise *promise in allPromises) { //保证所有promise都已经被处理
                        if (promise.isPending) {
                            return;
                        }
                    }
                    reject(error);
                } else {
                    reject(error);
                }
            }];
        }
        
    }];
}

@end
