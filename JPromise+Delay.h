//
//  JPromise+Delay.h
//  JPromise
//
//  Created by jams on 2020/5/14.
//

#import <JPromise/JPromise.h>

NS_ASSUME_NONNULL_BEGIN

@interface JPromise (Delay)

- (instancetype)j_delay:(NSTimeInterval)interval;

- (instancetype)onQueue:(dispatch_queue_t)queue j_delay:(NSTimeInterval)interval;

- (JPromise * (^)(NSTimeInterval))j_delay;

- (JPromise * (^)(dispatch_queue_t, NSTimeInterval))j_delayOn;


@end

NS_ASSUME_NONNULL_END
