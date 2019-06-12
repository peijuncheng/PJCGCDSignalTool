//
//  PJCGCDSignalTool.m
//  Housekeeping
//
//  Created by pei juncheng on 2019/5/29.
//  Copyright © 2019 pei juncheng. All rights reserved.
//

#import "PJCGCDSignalTool.h"

@implementation PJCGCDSignalTool

+(void)GCD_SignalAsyn:(NSArray<GCD_SignalBlock> *)blockArray notifiBlock:(void (^)(void))notify{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
   
    for (GCD_SignalBlock block in blockArray) {
        dispatch_group_async(group, queue, block);
    }
    
    dispatch_group_notify(group, queue, ^{
        if (notify) {
            notify();
        }
    });
}

@end
