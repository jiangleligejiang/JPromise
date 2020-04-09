//
//  CCPromise+Always.h
//  CCPlayLiveKit
//
//  Created by jams on 2020/4/7.
//  Copyright © 2020 netease. All rights reserved.
//

#import "JPromise.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^JPromiseAlwaysBlock)(void);

@interface JPromise (Always)

// promise完成fulfill或reject，都会在此处回调（ps:若设置target后cancel不会在此处回调），适用于一些通用操作，比如隐藏loading
- (JPromise *)j_always:(JPromiseAlwaysBlock)alwaysBlock;

- (JPromise *(^)(JPromiseAlwaysBlock))j_always;

@end

NS_ASSUME_NONNULL_END
