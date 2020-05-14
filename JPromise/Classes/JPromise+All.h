//
//  JPromise+All.h
//
//  Created by jams on 2020/1/2.
//  Copyright © 2020 netease. All rights reserved.
//

#import "JPromise.h"

NS_ASSUME_NONNULL_BEGIN

@interface JPromise (All)

+ (instancetype)j_all:(NSArray *)promises;

/*  保证按顺序返回一个NSArray的结果
*  promises返回的结果若分别为：@(1), @"string", @[@1, @"str"] => @[@(1), @"string", @[@1, @"str"]]
*
*  若promise返回的结果为nil，仍会在NSArray以NSNull对象保留
*  example：@(1), nil, @"str" => @[@(1), <null>, @"str"]
*
*  isContinue: 用于其中一个promise被rejected后，触发外部cc_catch的时机，默认值为NO；
               若isContinue为YES，则会等所有promise完成后才触发cc_catch；
               若isContinue为NO，则会在promise被rejected后，立即触发cc_catch；
    ps：只有所有的promise都被fulfill，外部的cc_then方法才会被调用
*/

+ (instancetype)j_all:(NSArray *)promises isContinue:(BOOL)isContinue;

@end

NS_ASSUME_NONNULL_END
