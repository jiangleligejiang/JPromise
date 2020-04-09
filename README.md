# JPromise

[![CI Status](https://img.shields.io/travis/jams/JPromise.svg?style=flat)](https://travis-ci.org/jams/JPromise)
[![Version](https://img.shields.io/cocoapods/v/JPromise.svg?style=flat)](https://cocoapods.org/pods/JPromise)
[![License](https://img.shields.io/cocoapods/l/JPromise.svg?style=flat)](https://cocoapods.org/pods/JPromise)
[![Platform](https://img.shields.io/cocoapods/p/JPromise.svg?style=flat)](https://cocoapods.org/pods/JPromise)

## Installation

JPromise is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'JPromise'
```

## 使用
> JPromise是基于[promises](https://github.com/google/promises) 和 [PromiseKit](https://github.com/mxcl/PromiseKit) 的封装，旨在处理一些复杂的业务流程，通过`j_then`方法将相关操作串联起来，提供 `fulfill `和 `reject` 来对该操作进行选择继续处理或拒绝。

### 一、基本使用

#### 1.初始化 `JPromise`
> `promiseWithValue:` 方法传入的对象若为 `NSError`，则相当于 `promiseWithBlock:` 方法调用了 `JPromiseRejectBlock`，反之，等同于调用了 `JPromiseFulfillBlock`。
- `promiseWithValue:`
```objc
BOOL successful = YES;
id value = successful ? @(1) : [NSError errorWithReason:@"failed"];

JPromise *promise = [JPromise promiseWithValue:value];
```
- `promiseWithBlock:`
```objc
JPromise *promise = [JPromise promiseWithBlock:^(JPromiseFulfillBlock  _Nonnull fulfill, JPromiseRejectBlock  _Nonnull reject) {
    BOOL successful = YES;
    if (successful) {
        fulfill(@(1));
    } else {
        reject([NSError errorWithReason:@"fail in promise block"]);
    }
}];
```

#### 2. `j_then` 方法
> `j_then:` 方法对应的block为可变参数block，目的是为了支持不定参数的声明方式。这样可能会造成代码的一些不便捷，为了解决这个问题，可以参考下面的自定义代码块。

```objc
JPromise *promise = [JPromise promiseWithBlock:^(JPromiseFulfillBlock  _Nonnull fulfill, JPromiseRejectBlock  _Nonnull reject) {
    BOOL successful = YES;
    if (successful) {
        fulfill(@(1));
    } else {
        reject([NSError errorWithReason:@"fail in promise block"]);
    }
}];

[[promise j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSNumber *value){
    // do something
    BOOL successful = YES;
    if (successful) {
        NSString *string = [NSString stringWithFormat:@"value-%@", value];
        fulfill(string);
    } else {
        reject([NSError errorWithReason:@"fail in then block"]);
    }
}] j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSString *value){
    // do something
}];
```
关于 `j_then`操作中的参数定义通常为 `(JPromiseFulfillBlock fulfill, JPromiseReject reject, xxx)`，前两个为固定参数，后面的参数需与上一个`fulfill`传入的对象相同。

```
fullfil(@(1)) -> j_then:^(..., NSNumber *value) -> fulfill(string) -> j_then:^(..., NSString *value)
```

#### 3. `j_catch` 方法
> 若在流程中调用了 `JPromiseRejectBlock` ，则会中断整个流程，并在 `j_catch` 方法中获取到对应的 `NSError`对象。

```objc
JPromise *promise = [JPromise promiseWithBlock:^(JPromiseFulfillBlock  _Nonnull fulfill, JPromiseRejectBlock  _Nonnull reject) {
    BOOL successful = NO;
    if (successful) {
        fulfill(@(1));
    } else {
        reject([NSError errorWithReason:@"fail in promise block"]);
    }
}];

[[promise j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSNumber *value){
    // do something
    BOOL successful = YES;
    if (successful) {
        NSString *string = [NSString stringWithFormat:@"value-%@", value];
        fulfill(string);
    } else {
        reject([NSError errorWithReason:@"fail in then block"]);
    }
}] j_catch:^(NSError * _Nonnull error) {
    // error: fail in promise block
}];
```
#### 4. `j_always` 方法
> 当流程处理完成或被中断，`j_always` 方法都会被调用。可以考虑在这做一些通用的业务，比如业务请求失败或成功后隐藏loading视图。

```objc
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
    // do some common things
}];
```
对于 `j_always` 方法需要注意一点：对于最后一个 `j_then` 方法必须要调用 `fulfill block` 将数据传往下传递，若数据并非业务需要，传递为 `nil` 即可。
```objc
[[[[[JPromise promiseWithValue:@(1)] j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSNumber *value){
    fulfill([NSString stringWithFormat:@"value-%@", value]);
}] j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSString *value){
    fulfill(@[value, @"value2"]);
}] j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSArray *values){
    // 完成流程后，为了保证`j_always`方法被调用，需要调用fulfill
    fulfill(nil);
}] j_always:^{
    
}];
```
### 二、更多使用
#### 1. `j_then` 方法的多参数传递
> `JPromiseFulfillBlock` 只能传递一个 `id` 参数，若流程中需要传递多个参数，则可使用 `JPromiseArr` 宏，内部会将其转换为一个 `JPromiseArray` 对象，并在下面的 `j_then` 方法中按传入顺序分别添加到 `j_then block` 中。

``` objc
[[[[JPromise promiseWithBlock:^(JPromiseFulfillBlock  _Nonnull fulfill, JPromiseRejectBlock  _Nonnull reject) {

    fulfill(JPromiseArr(@"num1", @(2)));
}] j_then:^(JPromiseFulfillBlock fulfill,JPromiseRejectBlock reject, NSString *str, NSNumber *num){

    fulfill(@[str, num]);
}] j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSArray *arr){

    NSDictionary *dict = @{@"key1": @"value1", @"key2" : @(2)};
    fulfill(JPromiseArr(arr, dict, @3, @4, @5, @6));
}] j_then:^(JPromiseFulfillBlock fulFill, JPromiseRejectBlock reject, NSArray *arr, NSDictionary *dict, NSNumber *num3, NSNumber *num4, NSNumber *num5, NSNumber *num6){
    // do something
    fulFill(nil);
}];
```

-  `j_then block` 的参数：前两个参数固定为 `JPromiseFulfillBlock` 和 `JPromiseRejectBlock`，后面的参数则为 `JPromiseArr` 传递进来的参数。

```objc
JPromiseArr(@"num1", @(2)) -> (..., NSString *str, NSNumber *num)
JPromiseArr(arr, dict, @3, @4, @5, @6) -> (..., NSArray *arr, NSDictionary *dict, NSNumber *num3, NSNumber *num4, NSNumber *num5, NSNumber *num6)
```

- `JPromiseArr` 宏最多支持6个参数，若超过这个限制，则会出错，针对这种场景，可以考虑使用`NSArray`对象。

#### 2. `JPromise` 的异步操作
> 使用 `onQueue:j_then:` 方法，可以使得 `j_then` 中的 `block` 可以在传入的 `queue` 中执行。

```objc
[[[[JPromise promiseWithBlock:^(JPromiseFulfillBlock  _Nonnull fulfill, JPromiseRejectBlock  _Nonnull reject) {
    // in main queue
    fulfill(@"first string");
}] onQueue:dispatch_queue_create("queue1", 0) j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSString *str){
    // in queue1
    fulfill(JPromiseArr(str, @"second string"));
}] onQueue:dispatch_queue_create("queue2", 0) j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSString *str1, NSString *str2){
    // in queue2
    fulfill(JPromiseArr(str1, str2, @"third string"));
}] j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSString *str1, NSString *str2, NSString *str3){
    // in main queue
    fulfill(nil);
}];
```
`j_then` 方法是在**主队列**中执行的，不会延续上一个 `onQueue:j_then:` 中所传递的 `queue`。

> 使用 `j_thenAsync:` 方法，使其在默认的异步队列 `JPromise.defaultAsyncQueue`中执行异步操作

```objc
[[[[JPromise promiseWithBlock:^(JPromiseFulfillBlock  _Nonnull fulfill, JPromiseRejectBlock  _Nonnull reject) {
        
    fulfill(@1);
}] j_thenAsync:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock rejct, NSNumber *value){
    // in default async queue
    fulfill([NSString stringWithFormat:@"value-%@", value]);
}] j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSString *value){
    // in main queue
    fulfill(JPromiseArr(value, @"value-2"));
}] j_thenAsync:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock rejct, NSString *str1, NSString *str2){
    // in default async queue
    fulfill(nil);
}];
```


#### 3. `JPromise`的生命周期
> 一般而言，`JPromise` 对象的生命周期是与外部调用者无关的，比如在一个 `ViewController` 调用了 `JPromise` 对象去执行异步操作，如果 `ViewController` 被释放了，而 `JPromise` 对象未执行完，它会继续执行完成，并回调相关 `block`。

> 若业务场景需要将 `JPromise` 对象和外部调用者生命周期绑定，则可以在创建 `JPromise` 时，调用 `promiseWithValue:target` 或 `promiseWithBlock:target` 方法，通常 `target` 为外部调用者 `self`。内部会持有外部调用者的弱引用，当调用者被释放后，`JPromise` 流程会被自动取消，并通过 `j_cancel` 方法通知给外部。

```objc
JPromise *promise = [JPromise promiseWithValue:@(1) target:self]; //传入外部调用者self
dispatch_queue_t queue = dispatch_queue_create("com.j.promise.queue", DISPATCH_QUEUE_SERIAL);

[[[[[[promise onQueue:queue j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSNumber *value){
    // 模拟耗时
    sleep(3);
    fulfill([NSString stringWithFormat:@"value-%@", value]);
}] onQueue:queue j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSString *value){
    // 模拟耗时
    sleep(5);
    fulfill(JPromiseArr(value, @(2)));
}] j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSString *str, NSNumber *num){
    // 完成流程
    fulfill(nil);
}] j_catch:^(NSError * _Nonnull error) {
   
}] j_cancel:^{
   // 若流程被取消，这里会被回调
}] j_always:^{
   // 对于取消事件，这里不会被回调，只会监听到流程结束或中断事件
}];
```
#### 4. 点操作
- `JPromise` 的点操作
```objc
JPromise *promise = [JPromise promiseWithValue:@(1)];
dispatch_queue_t queue = dispatch_queue_create("queue", 0);

promise.j_then(^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSNumber *value){

    fulfill([NSString stringWithFormat:@"value-%@", value]);
}).j_thenOn(queue, ^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSString *value){

    sleep(3);
    fulfill(@[value, @"string2"]);
}).j_then(^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSArray *value){

    BOOL success = YES;
    if (success) {
        fulfill(@(value.count));
    } else {
        reject([NSError errorWithReason:@"j-promsie-thenblock2 error"]);
    }
}).j_then(^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSNumber *value){

    fulfill(value);
}).j_catch(^(NSError * _Nonnull error) {

}).j_always(^{

}).j_cancel(^{

});
```

#### 5. `j_all` 方法
> `j_all` 方法：传入一个 `NSArray<JPromise *>` 对象，保证 `NSArray` 中的 `JPromise` 对象都完成后，回调 `j_then` block，若其中一个对象出错，则回调 `j_catch` block。

```objc
JPromise *allPromises = [JPromise j_all:@[promise1, promise2, promise3]];
[[allPromises j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSArray *values){
    
    // 完成所有promise
    fulfill(nil);
}] j_catch:^(NSError *error) {
    // 其中一个promise出错
}];
```

### 三、注意事项

#### 1. 自定义代码块
> 上面提及到了 `JPromiseThenBlock` 为一个可变参数的 `block`，而在 `block`内需要根据业务进行 `fulfill` 或 `reject` 操作。因此，手动在 `JPromiseThenBlock` 中添加 `JPromiseFulfillBlock` 和 `JPromiseRejectBlock` 参数。为了避免这种方式的不便捷性，可以通过自定义代码块来实现。

> x-code在代码中**右键->create code snippet**

- `j_then` 操作
```
summary: JPromise中的j_then操作
completion: j_then

j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, <#parameters#>){
    
}
```

- `onQueue:j_then`操作
```
summary: JPromise中onQueue:j_then操作
completion: onQueue

onQueue:<#dispatchQueue#> j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, <#parameters#>){
    
}
```

- `j_thenAsync` 操作
```
summary: JPromise中j_thenAsync操作
completion: j_thenAsync

j_thenAsync:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock rejct, <#parameters#>){
    
}
```

**如果习惯使用点操作，也可以定义对应的一些点操作方法**

- `j_then` 的点操作
```
summary: JPromise中j_then的点操作
completion: j_then

j_then(^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, <#parameters#>){
    
})
```

- `j_thenOn` 的点操作
```
summary: JPromise中的j_thenOn点操作
completion: j_thenOn

j_thenOn(<#dispatchQueue#>, ^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, <#parameters#>){
    
})
```

- `j_thenAsync`的点操作

```
summary: JPromise中的j_thenAsync点操作
completion: j_thenAsync

j_thenAsync(^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, <#parameters#>){
    
})
```

- `j_catch` 的点操作
```
summary: JPromise中的j_catch点操作
completion: j_catch

j_catch(^(NSError * _Nonnull error) {
    
})
```

- `j_always` 的点操作

```
summary: JPromise中的j_always点操作
completion: j_always

j_always(^{
          
})
```

- `j_cancel` 的点操作

```
summary: JPromise中的j_cancel点操作
completion: j_cancel

j_cancel(^{
          
})
```
**以上自定义代码只是参考，可根据个人习惯，定义不同的形式**

#### 2. 常见误区
- 误区1： `JPromise` 初始化后，后面的操作都可以使用。

```objc
JPromise *promise = [JPromise promiseWithValue:@(1)];
    
[[promise j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSNumber *value){
    // receive: @(1)
    fulfill(JPromiseArr(value, @"string"));
}] j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSNumber *value, NSString *string){
    // receive: @(1), @"string"
    fulfill(@[value, string]);
}];

[promise j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSArray *arr){
    //error：这里获取的并不是上面传递的 @[@(1), @"string"], 而是最开始的传递的 @(1) !!!
}];
```
实际上 `JPromise` 每调用一次方法，都会创建一个新的 `JPromise`对象。因此，如果要继续延续上面的操作，应该使用上一个返回的 `JPromise`对象，而不是最开始初始化的对象。如下所示：

```objc
JPromise *promise = [JPromise promiseWithValue:@(1)];

JPromise *promise2 = [[promise j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSNumber *value){

    fulfill(JPromiseArr(value, @"string"));
}] j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSNumber *value, NSString *string){

    // receive: @(1), @"string"
    fulfill(@[value, string]);
}];

// 使用上面返回的对象，而非最开始初始化的对象
[promise2 j_then:^(JPromiseFulfillBlock fulfill, JPromiseRejectBlock reject, NSArray *arr){
    //receive: @[@(1), @"string"]
    fulfill(nil);
}];
```


## Author

jams, 1411702600@qq.com

## License

JPromise is available under the MIT license. See the LICENSE file for more info.
