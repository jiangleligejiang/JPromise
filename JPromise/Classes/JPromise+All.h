//
//  CCPromise+All.h
//  CCPlayLiveKit
//
//  Created by jams on 2020/1/2.
//  Copyright © 2020 netease. All rights reserved.
//

#import "JPromise.h"

NS_ASSUME_NONNULL_BEGIN

@interface JPromise (All)

/*  保证按顺序返回一个NSArray的结果
 *  promises返回的结果若分别为：@(1), @"string", @[@1, @"str"] => @[@(1), @"string", @[@1, @"str"]]
 *
 *  若promise返回的结果为nil，仍会在NSArray以NSNull对象保留
 *  example：@(1), nil, @"str" => @[@(1), <null>, @"str"]
 */

+ (instancetype)j_all:(NSArray *)promises;

@end

NS_ASSUME_NONNULL_END
