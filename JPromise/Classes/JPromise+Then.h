//
//  JPromise+Then.h
//  
//
//  Created by jams on 2020/4/7.
//  Copyright © 2020 netease. All rights reserved.
//

#import "JPromise.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^JPromiseThenBlock)();

@interface JPromise (Then)

- (JPromise *)j_then:(JPromiseThenBlock)thenBlock;

- (JPromise *)j_thenAsync:(JPromiseThenBlock)thenBlock; // 提供异步操作，默认使用JPromise.defaultAsyncQueue

- (JPromise *)onQueue:(_Nullable dispatch_queue_t)queue j_then:(JPromiseThenBlock)thenBlock;

- (JPromise* (^)(id))j_then;

- (JPromise* (^)(id))j_thenAsync;

- (JPromise* (^)(_Nullable dispatch_queue_t, id))j_thenOn;

@end

NS_ASSUME_NONNULL_END
