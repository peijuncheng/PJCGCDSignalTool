//
//  ViewController.m
//  PJCGCDSignalTool
//
//  Created by pei juncheng on 2019/6/12.
//  Copyright © 2019 pei juncheng. All rights reserved.
//

#import "ViewController.h"
#import "PJCGCDSignalTool.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //信号量方法
    [self signalMethod];
    
    //队列group进出方法
//    [self groupInOut];
}


#pragma mark - 信号量方法
- (void)signalMethod{
    NSLog(@"信号量方法演示");
    //为什么一开始要设置信号量为0呢？按照上面的说法，信号量为0不就一直卡住当前线程了么？其实这正是我们想要的效果，想象一下，当我们程序走到dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);这句代码时，因为信号量为0，所以当前线程阻塞不会继续往下执行，但是网络请求成功之后（在代码中是走了随机的几秒）会执行block块中的dispatch_semaphore_signal(sema);代码，使得信号量+1，而wait函数此时监测到信号量大于0 ，便继续往下执行。这样才能保证全部网络请求完成之后再进行最终操作。
    //简书：https://www.jianshu.com/p/15e7f317fbe0
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [PJCGCDSignalTool GCD_SignalAsyn:@[^{
        [self getBannerSuccess:^{
            NSLog(@"完成获取Banner请求成功！");
            dispatch_semaphore_signal(semaphore);//signal相当于V操作，发送一个信号，即信号量+1；
        } fail:^{
            NSLog(@"完成获取Banner请求失败！");
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);//wait相当于P操作，即对信号量值-1,信号量为0的话便一直阻塞，直到监测到信号量大于0，才继续往下执行//等待信号直到信号量大于0
    },^{
        [self checkVersionSuccess:^{
            NSLog(@"检查版本更新成功！");
            dispatch_semaphore_signal(semaphore);
        } fail:^{
            NSLog(@"检查版本更新失败！");
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }] notifiBlock:^{
        NSLog(@"任务完成刷新界面！");
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"执行具体操作！");
        });
    }];
}


#pragma mark - 队列进出方法
- (void)groupInOut{
    NSLog(@"队列进出方法演示");
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_group_enter(group);
        [self getBannerSuccess:^{
            NSLog(@"完成获取Banner请求成功！");
            dispatch_group_leave(group);
        } fail:^{
            NSLog(@"完成获取Banner请求失败！");
            dispatch_group_leave(group);
        }];
    });
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_group_enter(group);
        [self checkVersionSuccess:^{
            NSLog(@"检查版本更新成功！");
            dispatch_group_leave(group);
        } fail:^{
            NSLog(@"检查版本更新失败！");
            dispatch_group_leave(group);
        }];
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"任务完成刷新界面！");
    });
}


#pragma mark - 获取banner
- (void)getBannerSuccess:(void(^)(void))success fail:(void(^)(void))fail{
    /** 利用随机数和延迟函数模拟网络请求*/
    int random = arc4random() % 10;
    NSLog(@"获取Banner请求延时 = %d秒",random);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(random * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        success();
    });
}


#pragma mark - 检查版本更新
- (void)checkVersionSuccess:(void(^)(void))success fail:(void(^)(void))fail{
    int random = arc4random() % 10;
    NSLog(@"检查版本更新请求延时 = %d秒",random);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(random * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        fail();
    });
}


@end
