//
//  JPromiseArray.m
//  
//
//  Created by jams on 2020/1/2.
//  Copyright © 2020 netease. All rights reserved.
//

#import "JPromiseArray.h"

id JPromiseArrayWithCount(NSUInteger count, ...) {
    JPromiseArray *arr = [JPromiseArray new];
    arr->count = count;
    NSCAssert(count > 0 && count < 8, @"invalid parameter nums");
    va_list args;
    va_start(args, count);
    for (NSInteger index = 0; index < count; index ++) {
        id obj = va_arg(args, id);
        arr->objs[index] = obj;
    }
    va_end(args);
    return arr;
}


@implementation JPromiseArray

- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    if (idx < count) {
        return objs[idx];
    }
    return nil;
}

@end


