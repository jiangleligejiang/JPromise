#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "JPromise+Internal.h"
#import "JPromiseInternal.h"
#import "NSMethodSignatureForBlock.h"
#import "JPromise+All.h"
#import "JPromise+Always.h"
#import "JPromise+Cancel.h"
#import "JPromise+Catch.h"
#import "JPromise+Then.h"
#import "JPromise.h"
#import "JPromiseArray.h"
#import "JPromiseDefine.h"
#import "NSError+Promise.h"

FOUNDATION_EXPORT double JPromiseVersionNumber;
FOUNDATION_EXPORT const unsigned char JPromiseVersionString[];

