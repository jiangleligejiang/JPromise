//
//  JPromiseExample.m
//  CCPlayLiveKit
//
//  Created by jams on 2020/1/2.
//  Copyright © 2020 netease. All rights reserved.
//

#import "JPromiseExample.h"
#import "JPromiseDefine.h"

@implementation JPromiseExample

- (void)dealloc {
    NSLog(@"j-promise example dealloc");
}

- (void)test {
    [self testDotThenBlock2];
}

- (void)blockExample {
//    BOOL successful = YES;
//    id value = successful ? @(1) : [NSError errorWithReason:@"failed"];
//    JPromise *promise = [JPromise promiseWithValue:value];
    
    JPromise *promise = [JPromise promiseWithBlock:^(JPromiseFulfillBlock  _Nonnull fulfill, JPromiseRejectBlock  _Nonnull reject) {
        BOOL successful = NO;
        if (successful) {
            fulfill(@(1));
        } else {
            reject([NSError errorWithReason:@"fail in promise block"]);
        }
    }];
    
    [[[promise j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSNumber *value){
        BOOL successful = YES;
        if (successful) {
            NSString *string = [NSString stringWithFormat:@"value-%@", value];
            fulfill(string);
        } else {
            reject([NSError errorWithReason:@"fail in then block"]);
        }
    }] j_catch:^(NSError * _Nonnull error) {
        // error: fail in promise block
    }] j_always:^{
        // do something
    }];
    
    [[[[[JPromise promiseWithValue:@(1)] j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSNumber *value){
        fulfill([NSString stringWithFormat:@"value-%@", value]);
    }] j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSString *value){
        fulfill(@[value, @"value2"]);
    }] j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSArray *values){
        // 完成业务，为了保证`j_always`方法被调用，需要调用fulfill
        fulfill(nil);
    }] j_always:^{
        
    }];
}

- (void)chainExample {
    JPromise *promise = [[[[[JPromise promiseWithBlock:^(JPromiseFulfillBlock  _Nonnull fulfill, JPromiseRejectBlock  _Nonnull reject) {
        BOOL successful = YES;
        if (successful) {
            fulfill(@(1));
        } else {
            reject([NSError errorWithReason:@"fail in promise block"]);
        }
    }] j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSNumber *value){
        NSLog(@"j-promise-chain-example: enter first then block with %@", value);
        BOOL successful = YES;
        if (successful) {
            fulfill([NSString stringWithFormat:@"value-%@", value]);
        } else {
            reject([NSError errorWithReason:@"fail in first then block"]);
        }
    }] j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSString *str){
        NSLog(@"j-promise-chain-example: enter second then block with %@", str);
        fulfill(@[str, @"str from second then block"]);
    }] j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSArray *arr){
        NSLog(@"j-promise-chain-example: enter third then block with %@", arr);
        fulfill(arr);
    }] j_catch:^(NSError * _Nonnull error) {
        NSLog(@"j-promise-chain-error: %@", error.errorReason);
    }];
    
    [[promise j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSArray *value){
        NSLog(@"j-promise-chain-result: %@", value);
    }] j_catch:^(NSError * _Nonnull error) {
        NSLog(@"j-promise-chain-result-error: %@", error.errorReason);
    }];
}

- (void)multiParameterExample {
    [[[[JPromise promiseWithBlock:^(JPromiseFulfillBlock  _Nonnull fulfill, JPromiseRejectBlock  _Nonnull reject) {
        fulfill(JPromiseArr(@"num1", @(2)));
    }] j_then:^(JPromiseFulfillBlock fulfill,JPromiseRejectBlock reject, NSString *str, NSNumber *num){
        NSLog(@"j-promise-multi-example: enter first then block with %@, %@", str, num);
        fulfill(@[str, num]);
    }] j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSArray *arr){
        NSLog(@"j-promise-multi-example: enter second then block with %@", arr);
        NSDictionary *dict = @{@"key1": @"value1", @"key2" : @(2)};
        fulfill(JPromiseArr(arr, dict, @3, @4, @5, @6));
    }] j_then:^(JPromiseFulfillBlock fulFill, JPromiseRejectBlock reject, NSArray *arr, NSDictionary *dict, NSNumber *num3, NSNumber *num4, NSNumber *num5, NSNumber *num6){
        NSLog(@"j-promise-multi-example: enter third then block with arr:%@, dict:%@, %@, %@, %@, %@", arr, dict, num3, num4, num5, num6);
        fulFill(nil);
    }];
}

- (void)allPromiseExample {
    JPromise *promise1 = [[JPromise promiseWithValue:@(1)] j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSNumber *num){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString *str = [NSString stringWithFormat:@"value-%@", num];
            NSLog(@"j-promise-all-example promise1 send : %@", str);
            fulfill(str);
        });
    }];
    JPromise *promise2 = [JPromise promiseWithBlock:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            BOOL successful = YES;
            if (successful) {
                NSArray *arr = @[@(2), @"str3"];
                NSLog(@"j-promise-all-example promise2 send : %@", arr);
                fulfill(arr);
            } else {
                reject([NSError errorWithReason:@"fail in promise2"]);
            }
        });
    }];
    
    JPromise *promise3 = [[JPromise promiseWithBlock:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            BOOL successful = YES;
            if (successful) {
                fulfill(JPromiseArr(@"str4", @(5), @"str6"));
            } else {
                reject([NSError errorWithReason:@"fail in promise3"]);
            }
        });
    }] j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSString *str1, NSNumber *num, NSString *str2){
        NSDictionary *dict = @{@"key1" : str1, @"key2" : num, @"key3" : str2};
        NSLog(@"j-promise-all-example promise3 send : %@", dict);
        fulfill(dict);
    }];
    
    JPromise *allPromises = [JPromise j_all:@[promise1, promise2, promise3]];
    [[allPromises j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSArray *values){
        NSLog(@"j-promise-all-example: %@", values);
        id dict = values[2];
        if (![dict isKindOfClass:[NSNull class]]) {
            NSLog(@"j-promise-all-example promise3 result : %@", dict);
        } else {
            NSLog(@"j-promise-all-example promise3 result is nil");
        }
    }] j_catch:^(NSError *error) {
        NSLog(@"j-promise-all-error: %@", error.errorReason);
    }];
}

- (void)defaultAsyncQueueExample {
    [[[[JPromise promiseWithBlock:^(JPromiseFulfillBlock  _Nonnull fulfill, JPromiseRejectBlock  _Nonnull reject) {
        
        fulfill(@1);
    }] j_thenAsync:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock rejct, NSNumber *value){
        
        NSLog(@"j-promise first then block with value: %@ in thread: %@", value, [NSThread currentThread]);
        fulfill([NSString stringWithFormat:@"value-%@", value]);
    }] j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSString *value){
        
        NSLog(@"j-promise second then block with value: %@ in thread: %@", value, [NSThread currentThread]);
        fulfill(JPromiseArr(value, @"value-2"));
    }] j_thenAsync:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock rejct, NSString *str1, NSString *str2){
        
        NSLog(@"j-promise third then block with value: %@, %@ in thread: %@", str1, str2, [NSThread currentThread]);
        fulfill(nil);
    }];

}

- (void)asyncQueueExample {
    
    
    [[[[JPromise promiseWithBlock:^(JPromiseFulfillBlock  _Nonnull fulfill, JPromiseRejectBlock  _Nonnull reject) {
        fulfill(@"first string");
    }] onQueue:JPromise.defaultAsyncQueue j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSString *str){
        sleep(2);
        NSLog(@"j-promise-async-example receive value:%@ in queue(%@)", str, [NSThread currentThread]);
        sleep(3);
        fulfill(JPromiseArr(str, @"second string"));
    }] onQueue:JPromise.defaultAsyncQueue j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSString *str1, NSString *str2){
        sleep(3);
        NSLog(@"j-promise-async-example receive value:%@, %@ in queue(%@)", str1, str2, [NSThread currentThread]);
        sleep(2);
        fulfill(JPromiseArr(str1, str2, @"third string"));
    }] j_then:^(NSString *str1, NSString *str2, NSString *str3){
        NSLog(@"j-promise-async-example receive value:%@, %@, %@ in queue(%@)", str1, str2, str3, [NSThread currentThread]);
    }];
    
    /*
    dispatch_queue_t queue = dispatch_queue_create("queue", 0);
    dispatch_async(queue, ^{
        [[[[JPromise promiseWithBlock:^(JPromiseFulfillBlock  _Nonnull fulfill, JPromiseRejectBlock  _Nonnull reject) {
            NSLog(@"j-promise first block in thread: %@", [NSThread currentThread]);
            fulfill(@(1));
        }] j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSNumber *value){
            NSLog(@"j-promise second block with value: %@ in thread: %@", value, [NSThread currentThread]);
            fulfill(JPromiseArr(value, @"string"));
        }] onQueue:JPromise.defaultAsyncQueue j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSNumber *num, NSString *string){
            NSLog(@"j-promise third block with value: %@, %@ in thread: %@", num, string, [NSThread currentThread]);
            fulfill(@[num, string]);
        }] j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSArray *arr){
            NSLog(@"j-promise forth block with value: %@ in thread: %@", arr, [NSThread currentThread]);
            fulfill(nil);
        }];
    });
     */
}

// 与JPromiseExample生命周期绑定，当JPromiseExample被释放后，JPromise若还在执行流程，则会取消相关流程
- (void)cancelPromiseTest {
    JPromise *promise = [JPromise promiseWithValue:@(1) target:self];
    dispatch_queue_t queue = dispatch_queue_create("com.j.promise.queue", DISPATCH_QUEUE_SERIAL);
    NSLog(@"j-promise start in %@", [NSDate date]);
    
    [[[[[[promise onQueue:queue j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSNumber *value){
        NSLog(@"j-promise receive first result: %@ in %@", value, [NSDate date]);
        sleep(3);
        fulfill([NSString stringWithFormat:@"value-%@", value]);
    }] onQueue:queue j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSString *value){
        NSLog(@"j-promise receive second result: %@ in %@", value, [NSDate date]);
        sleep(5);
        fulfill(JPromiseArr(value, @(2)));
    }] j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSString *str, NSNumber *num){
        NSLog(@"j-promise receive third result: %@,%@ in %@", str, num, [NSDate date]);
        fulfill(nil);
    }] j_catch:^(NSError * _Nonnull error) {
        NSLog(@"j-promise receive error event in %@", [NSDate date]);
    }] cc_cancel:^{
        NSLog(@"j-promise receive cancel event in %@", [NSDate date]);
    }] j_always:^{
        NSLog(@"j-promise receive always event in %@", [NSDate date]);
    }];
}

// 不与JPromiseExample生命周期绑定，当JPromiseExample被释放后，JPromise若还在执行流程，会继续执行相关流程
- (void)continuePromiseTest {
    JPromise *promise = [JPromise promiseWithValue:@(1)];
    dispatch_queue_t queue = dispatch_queue_create("com.j.promise.queue", DISPATCH_QUEUE_SERIAL);
    NSLog(@"j-promise start in %@", [NSDate date]);
    
    [[[[[promise onQueue:queue j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSNumber *value){
        NSLog(@"j-promise receive first result: %@ in %@", value, [NSDate date]);
        sleep(3);
        fulfill([NSString stringWithFormat:@"value-%@", value]);
    }] onQueue:queue j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSString *value){
        NSLog(@"j-promise receive second result: %@ in %@", value, [NSDate date]);
        sleep(5);
        reject([NSError errorWithReason:@"always error event"]);
        //fulfill(JPromiseArr(value, @(2)));
    }] j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSString *str, NSNumber *num){
        NSLog(@"j-promise receive third result: %@,%@ in %@", str, num, [NSDate date]);
        fulfill(JPromiseArr(str, num));
    }] j_catch:^(NSError * _Nonnull error) {
        NSLog(@"j-promise receive error event in %@", [NSDate date]);
    }] cc_cancel:^{
        NSLog(@"j-promise receive cancel event in %@", [NSDate date]);
    }];
}

- (void)alwaysTest {
     JPromise *promise = [JPromise promiseWithValue:@(1)];
    dispatch_queue_t queue = dispatch_queue_create("com.j.promise.queue", DISPATCH_QUEUE_SERIAL);
    NSLog(@"j-promise start in %@", [NSDate date]);
    
    [[[[[[promise onQueue:queue j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSNumber *value){
        NSLog(@"j-promise receive first result: %@ in %@", value, [NSDate date]);
        sleep(3);
        fulfill([NSString stringWithFormat:@"value-%@", value]);
    }] onQueue:queue j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSString *value){
        NSLog(@"j-promise receive second result: %@ in %@", value, [NSDate date]);
        sleep(5);
        reject([NSError errorWithReason:@"always error event"]);
        //fulfill(JPromiseArr(value, @(2)));
    }] j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSString *str, NSNumber *num){
        NSLog(@"j-promise receive third result: %@,%@ in %@", str, num, [NSDate date]);
#warning 如果设置了j_always，则最后一个j_then也必须调用fulfill或reject，否则j_always block会无法被调用
        fulfill(JPromiseArr(str, num));
    }] j_catch:^(NSError * _Nonnull error) {
        NSLog(@"j-promise receive error event in %@", [NSDate date]);
    }] cc_cancel:^{
        NSLog(@"j-promise receive cancel event in %@", [NSDate date]);
    }] j_always:^{
        NSLog(@"j-promise receive always event in %@", [NSDate date]);
    }];
}

- (void)testThenBlock2 {
    JPromise *promise = [JPromise promiseWithValue:@(1)];
    [[[[[[promise j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSNumber *value){
        NSLog(@"j-promise-thenblock2 receive first value: %@", value);
        fulfill([NSString stringWithFormat:@"value-%@", value]);
    }] j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSString *value){
        NSLog(@"j-promise-thenblock2 receive second value: %@", value);
        fulfill(@[value, @"string2"]);
    }] j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSArray *value){
        NSLog(@"j-promise-thenblock2 receive third value: %@", value);
        BOOL success = YES;
        if (success) {
            fulfill(@(value.count));
        } else {
            reject([NSError errorWithReason:@"j-promsie-thenblock2 error"]);
        }
    }] j_then:^(NSNumber *value){
        NSLog(@"j-promise-thenblock2 receive forth value: %@", value);
    }] j_catch:^(NSError * _Nonnull error) {
        NSLog(@"j-promise-thenblock2 receive error: %@", error.errorReason);
    }] j_always:^{
        NSLog(@"j-promise-thenblock2 receive always event");
    }];
}

- (void)testDotThenBlock2 {
    JPromise *promise = [JPromise promiseWithValue:@(1)];
    dispatch_queue_t queue = dispatch_queue_create("queue", 0);
    promise.j_then(^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSNumber *value){
        NSLog(@"j-promise-thenblock2 receive first value: %@", value);
        fulfill([NSString stringWithFormat:@"value-%@", value]);
    }).j_thenOn(queue, ^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSString *value){
        NSLog(@"j-promise-thenblock2 receive second value: %@", value);
        sleep(3);
        fulfill(@[value, @"string2"]);
    }).j_then(^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSArray *value){
        NSLog(@"j-promise-thenblock2 receive third value: %@", value);
        BOOL success = YES;
        if (success) {
            fulfill(@(value.count));
        } else {
            reject([NSError errorWithReason:@"j-promsie-thenblock2 error"]);
        }
    }).j_then(^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSNumber *value){
        NSLog(@"j-promise-thenblock2 receive forth value: %@", value);
        fulfill([NSString stringWithFormat:@"value-%@", value]);
    }).j_thenAsync(^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSString *value){
        NSLog(@"j-promise-thenblock2 receive fifth value: %@ in thread: %@", value, [NSThread currentThread]);
        fulfill(@[value, @"value-2"]);
    }).j_catch(^(NSError * _Nonnull error) {
        NSLog(@"j-promise-thenblock2 receive error: %@", error.errorReason);
    }).j_always(^{
        NSLog(@"j-promise-thenblock2 receive always event");
    }).cc_cancel(^{
        NSLog(@"j-promise-thenblock2 receive cancel event");
    });
}

- (void)mistakeExample {
    JPromise *promise = [JPromise promiseWithValue:@(1)];
    
    JPromise *promise2 = [[promise j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSNumber *value){
        NSLog(@"j-promise-mistake value: %@", value);
        // receive: @(1)
        fulfill(JPromiseArr(value, @"string"));
    }] j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSNumber *value, NSString *string){
        NSLog(@"j-promise-mistake value: %@, %@", value, string);
        // receive: @(1), @"string"
        fulfill(@[value, string]);
    }];
    
    // 使用上面返回的对象，而非最开始初始化的对象
    [promise2 j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSArray *arr){
        //receive: @[@(1), @"string"]
        NSLog(@"j-promise-mistake value: %@", arr);
    }];
}

@end
