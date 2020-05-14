//
//  JPromise+Internal.h
//  
//
//  Created by jams on 2020/4/4.
//  Copyright © 2020 netease. All rights reserved.
//

#import "JPromise+Then.h"

NS_ASSUME_NONNULL_BEGIN

@interface JPromise (Internal)

- (void)callBlock:(JPromiseThenBlock)block withValue:(id)value withQueue:(dispatch_queue_t)queue completionBlock:(void(^)(_Nullable id))completionBlock;

@end

NS_ASSUME_NONNULL_END
