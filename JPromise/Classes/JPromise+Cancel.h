//
//  JPromise+Cancel.h
//  
//
//  Created by jams on 2020/4/7.
//  Copyright © 2020 netease. All rights reserved.
//

#import "JPromise.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^JPromiseCancelBlock)(void);

@interface JPromise (Cancel)

// 获取到promise的取消操作
- (JPromise *)cc_cancel:(JPromiseCancelBlock)cancelBlock;

- (JPromise *(^)(JPromiseCancelBlock))cc_cancel;

@end

NS_ASSUME_NONNULL_END
