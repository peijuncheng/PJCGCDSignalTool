//
//  PJCGCDSignalTool.h
//  Housekeeping
//
//  Created by pei juncheng on 2019/5/29.
//  Copyright © 2019 pei juncheng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^GCD_SignalBlock)(void);//void的block块

@interface PJCGCDSignalTool : NSObject

+ (void)GCD_SignalAsyn:(NSArray <GCD_SignalBlock> *)blockArray notifiBlock:(void(^)(void))notify;

@end

NS_ASSUME_NONNULL_END
