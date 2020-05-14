//
//  JPromiseArray.h
//  
//
//  Created by jams on 2020/1/2.
//  Copyright © 2020 netease. All rights reserved.
//  用于方便构造参数的传递

#import <Foundation/Foundation.h>

#warning JPromiseArray最多支持6个参数,且仅支持NSObject对象，不支持类似int、double等类型，超过6个参数会出错，可以考虑换NSArray

#define JPromiseArr(...) __JPromiseArr(__VA_ARGS__, 6, 5, 4, 3, 2, 1)
#define __JPromiseArr(_1, _2, _3, _4, _5, _6, N, ...) JPromiseArrayWithCount(N, _1, _2, _3, _4, _5, _6)

NS_ASSUME_NONNULL_BEGIN

extern id JPromiseArrayWithCount(NSUInteger count, ...);

@interface JPromiseArray : NSObject {
@public
    id objs[6];
    NSUInteger count;
}
@end

NS_ASSUME_NONNULL_END
