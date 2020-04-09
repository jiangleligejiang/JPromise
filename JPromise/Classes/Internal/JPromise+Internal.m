//
//  CCPromise+Internal.m
//  CCPlayLiveKit
//
//  Created by jams on 2020/4/4.
//  Copyright © 2020 netease. All rights reserved.
//

#import "JPromise+Internal.h"
#import "NSMethodSignatureForBlock.h"
#import "JPromiseInternal.h"
#import "JPromiseArray.h"

#define _cc_promise_fulfill(completion) ^(id _Nullable value) { \
                                        completion(value); \
                                    }

#define _cc_promise_reject(completion) ^(NSError *error) { \
                                        completion(error); \
                                    }

NSInteger const kCCPromiseMinThenBlockArguments = 1;
NSInteger const kCCPromiseMaxThenBlockNoFulFillAndRejectArguments = 7;
NSInteger const kCCPromiseMaxThenBlockWithFulFillAndRejectArguments = 9;
NSInteger const kCCPromiseFulFillAndRejectThenBlockArguments = 3;
NSString *kJPromiseFulfillBlockAgrumentType = @"@?<v@?@>";
NSString *kJPromiseRejectBlockAgrumentType = @"@?<v@?@\"NSError\">";

@implementation JPromise (Internal)

- (void)callBlock:(JPromiseThenBlock)block withValue:(id)value withQueue:(dispatch_queue_t)queue completionBlock:(void (^)(id))completionBlock {
    
    @try {
        [self _callBlock:block withValue:value withQueue:queue completionBlock:completionBlock];
    } @catch (NSException *exception) {
        NSLog(@"`CCPromise` call block with exception: %@", (exception.reason ?: @""));
    }
}

- (void)_callBlock:(JPromiseThenBlock)thenBlock withValue:(id)value withQueue:(dispatch_queue_t)queue completionBlock:(void (^)(id))completion {
    NSMethodSignature *signature = NSMethodSignatureForBlock(thenBlock);
    const NSUInteger blockArguments = signature.numberOfArguments;
    
    NSString *fulfillArgumentType = nil;
    NSString *rejectArgumentType = nil;
    //检查block中是否存在`JPromiseFulfillBlock`和`JPromiseRejectBlock`
    if (blockArguments > kCCPromiseMinThenBlockArguments) {
        const char * argumentType = [signature getArgumentTypeAtIndex:1];
        NSString *argumentStr = [NSString stringWithUTF8String:argumentType];
        if ([argumentStr isEqualToString:kJPromiseFulfillBlockAgrumentType]) {
            fulfillArgumentType = argumentStr;
        }
        
        if (fulfillArgumentType.length > 0) { //存在fulfill-block的情况，检查reject-block参数是否存在
            if (blockArguments >= kCCPromiseFulFillAndRejectThenBlockArguments) {
                const char * argumentType = [signature getArgumentTypeAtIndex:2];
                NSString *argumentStr = [NSString stringWithUTF8String:argumentType];
                if ([argumentStr isEqualToString:kJPromiseRejectBlockAgrumentType]) {
                    rejectArgumentType = kJPromiseRejectBlockAgrumentType;
                }
            }
        }
    }
    
    if (fulfillArgumentType || rejectArgumentType) {
        NSAssert((fulfillArgumentType && rejectArgumentType), @"`JPromiseThenBlock`必须同时设置`JPromiseFulfillBlock`和`JPromiseRejectBlock`参数");
        
        if (fulfillArgumentType && rejectArgumentType) {
            NSAssert(blockArguments <= kCCPromiseMaxThenBlockWithFulFillAndRejectArguments, @"`JPromiseThenBlock`中的数据参数个数不能超过6个");
            if (blockArguments > kCCPromiseMaxThenBlockWithFulFillAndRejectArguments) { //超过参数个数不会处理
                NSLog(@"`JPromiseThenBlock`参数个数为: %@", @(blockArguments));
                return;
            }
        } else {
            NSLog(@"`JPromiseThenBlock`必须同时设置`JPromiseFulfillBlock`和`JPromiseRejectBlock`参数");
            return;
        }
    } else { //若不存在`JPromiseFulfillBlock`和`JPromiseRejectBlock`参数，则不进行处理
        NSAssert(blockArguments <= kCCPromiseMaxThenBlockNoFulFillAndRejectArguments, @"`JPromiseThenBlock`中的数据参数个数不能超过6个");
        
        if (blockArguments > kCCPromiseMaxThenBlockNoFulFillAndRejectArguments) {
            NSLog(@"`JPromiseThenBlock`参数个数为: %@", @(blockArguments));
            return;
        }
    }
    
        
    switch (blockArguments) {
        case 1: {
            dispatch_async(queue, ^{
                thenBlock();
                completion(nil);
            });
        }
            break;
        case 2: {
            void (^block)(id) = thenBlock;
            id result = [value isKindOfClass:[JPromiseArray class]] ? value[0] : value;
            dispatch_async(queue, ^{
                block(result);
                completion(nil);
            });
        }
        case 3:
        {
            if (fulfillArgumentType && rejectArgumentType) {
                void (^block)(JPromiseFulfillBlock, JPromiseRejectBlock) = thenBlock;
                dispatch_async(queue, ^{
                   block(_cc_promise_fulfill(completion), _cc_promise_reject(completion));
                });
            } else {
                void (^block)(id, id) = thenBlock;
                id param1, param2;
                if ([value isKindOfClass:[JPromiseArray class]]) {
                    param1 = value[0];
                    param2 = value[1];
                }
                dispatch_async(queue, ^{
                    block(param1, param2);
                    completion(nil);
                });
            }
        }
            break;
        
        case 4: {
            if (fulfillArgumentType && rejectArgumentType) {
                void (^block)(JPromiseFulfillBlock, JPromiseRejectBlock, id) = thenBlock;
                id param1;
                if ([value isKindOfClass:[JPromiseArray class]]) {
                    param1 = value[0];
                } else {
                    param1 = value;
                }
                dispatch_async(queue, ^{
                   block(_cc_promise_fulfill(completion), _cc_promise_reject(completion), param1);
                });
            } else {
                void (^block)(id, id, id) = thenBlock;
                
                id param1, param2, param3;
                if ([value isKindOfClass:[JPromiseArray class]]) {
                    param1 = value[0];
                    param2 = value[1];
                    param3 = value[2];
                }
                dispatch_async(queue, ^{
                    block(param1, param2, param3);
                    completion(nil);
                });
            }
        }
            break;
            
        case 5: {
            if (fulfillArgumentType && rejectArgumentType) {
                void (^block)(JPromiseFulfillBlock, JPromiseRejectBlock, id, id) = thenBlock;
                id param1, param2;
                if ([value isKindOfClass:[JPromiseArray class]]) {
                    param1 = value[0];
                    param2 = value[1];
                } else {
                    param1 = value;
                }

                dispatch_async(queue, ^{
                   block(_cc_promise_fulfill(completion), _cc_promise_reject(completion), param1, param2);
                });
            } else {
                void (^block)(id, id, id, id) = thenBlock;
                
                id param1, param2, param3, param4;
                if ([value isKindOfClass:[JPromiseArray class]]) {
                    param1 = value[0];
                    param2 = value[1];
                    param3 = value[2];
                    param4 = value[3];
                }
            
                dispatch_async(queue, ^{
                    block(param1, param2, param3, param4);
                    completion(nil);
                });
            }
        }
            break;
            
        case 6: {
            if (fulfillArgumentType && rejectArgumentType) {
                void (^block)(JPromiseFulfillBlock, JPromiseRejectBlock, id, id, id) = thenBlock;
                id param1, param2, param3;
                if ([value isKindOfClass:[JPromiseArray class]]) {
                    param1 = value[0];
                    param2 = value[1];
                    param3 = value[2];
                } else {
                    param1 = value;
                }
                
                dispatch_async(queue, ^{
                   block(_cc_promise_fulfill(completion), _cc_promise_reject(completion), param1, param2, param3);
                });
            } else {
                void (^block)(id, id, id, id, id) = thenBlock;
                
                id param1, param2, param3, param4, param5;
                if ([value isKindOfClass:[JPromiseArray class]]) {
                    param1 = value[0];
                    param2 = value[1];
                    param3 = value[2];
                    param4 = value[3];
                    param5 = value[4];
                }
                
                dispatch_async(queue, ^{
                    block(param1, param2, param3, param4, param5);
                    completion(nil);
                });
            }
        }
            break;
            
        case 7: {
            if (fulfillArgumentType && rejectArgumentType) {
                void (^block)(JPromiseFulfillBlock, JPromiseRejectBlock, id, id, id, id) = thenBlock;
                id param1, param2, param3, param4;
                if ([value isKindOfClass:[JPromiseArray class]]) {
                    param1 = value[0];
                    param2 = value[1];
                    param3 = value[2];
                    param4 = value[3];
                } else {
                    param1 = value;
                }
                
                dispatch_async(queue, ^{
                   block(_cc_promise_fulfill(completion), _cc_promise_reject(completion), param1, param2, param3, param4);
                });
            } else {
                void (^block)(id, id, id, id, id, id) = thenBlock;
                
                id param1, param2, param3, param4, param5, param6;
                if ([value isKindOfClass:[JPromiseArray class]]) {
                    param1 = value[0];
                    param2 = value[1];
                    param3 = value[2];
                    param4 = value[3];
                    param5 = value[4];
                    param6 = value[5];
                }

                dispatch_async(queue, ^{
                    block(param1, param2, param3, param4, param5, param6);
                    completion(nil);
                });
            }
        }
            break;
            
        case 8: {
            if (fulfillArgumentType && rejectArgumentType) {
                void (^block)(JPromiseFulfillBlock, JPromiseRejectBlock, id, id, id, id, id) = thenBlock;
                id param1, param2, param3, param4, param5;
                if ([value isKindOfClass:[JPromiseArray class]]) {
                    param1 = value[0];
                    param2 = value[1];
                    param3 = value[2];
                    param4 = value[3];
                    param5 = value[4];
                } else {
                    param1 = value;
                }
                
                dispatch_async(queue, ^{
                   block(_cc_promise_fulfill(completion), _cc_promise_reject(completion), param1, param2, param3, param4, param5);
                });
            }
        }
            break;
            
        case 9: {
            if (fulfillArgumentType && rejectArgumentType) {
                void (^block)(JPromiseFulfillBlock, JPromiseRejectBlock, id, id, id, id, id, id) = thenBlock;
                id param1, param2, param3, param4, param5, param6;
                if ([value isKindOfClass:[JPromiseArray class]]) {
                    param1 = value[0];
                    param2 = value[1];
                    param3 = value[2];
                    param4 = value[3];
                    param5 = value[4];
                    param6 = value[5];
                } else {
                    param1 = value;
                }

                dispatch_async(queue, ^{
                   block(_cc_promise_fulfill(completion), _cc_promise_reject(completion), param1, param2, param3, param4, param5, param6);
                });
            }
        }
            break;
    }
}

@end
