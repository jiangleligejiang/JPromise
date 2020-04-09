//
//  CCPromise+Catch.h
//  CCPlayLiveKit
//
//  Created by jams on 2020/4/7.
//  Copyright © 2020 netease. All rights reserved.
//

#import "JPromise.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^JPromiseCatchBlock)(NSError *error);

@interface JPromise (Catch)

- (JPromise *)j_catch:(JPromiseCatchBlock)catchBlock;

- (JPromise *(^)(JPromiseCatchBlock))j_catch;

@end

NS_ASSUME_NONNULL_END
