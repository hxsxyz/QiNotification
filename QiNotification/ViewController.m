//
//  ViewController.m
//  QiNotification
//
//  Created by wangdacheng on 2018/8/29.
//  Copyright © 2018年 dac. All rights reserved.
//

#import "ViewController.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

#define LocalNotiReqIdentifer    @"LocalNotiReqIdentifer"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"Notification"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    CGSize size = self.view.frame.size;
    CGFloat offset = 150;
    NSArray *titles = @[@"发送一个本地通知", @"移除一个本地通知"];
    for (int i=0; i<titles.count; i++) {
        NSString *title = [titles objectAtIndex:i];
        UIButton *btn = [self createCustomButton:title];
        btn.tag = i;
        [self.view addSubview:btn];
        btn.center = CGPointMake(size.width/2, offset);
        offset += btn.frame.size.height+10;
    }
}

- (UIButton *)createCustomButton:(NSString *)title {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(0, 0, self.view.frame.size.width-30, 45);
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [btn.layer setBorderColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.5].CGColor];
    [btn.layer setBorderWidth:1.0];
    [btn.layer setCornerRadius:5.0];
    [btn.layer setMasksToBounds:YES];
    return btn;
}

- (void)btnClicked:(UIButton *)button {
    if (button.tag == 0) {
        [self sendLocalNotification];
    } else if (button.tag == 1) {
        [self cancelLocalNotificaitons];
    }
}

#pragma mark - 发送一条本地推送通知
- (void)sendLocalNotification {
    
    NSString *title = @"通知-title";
    NSString *subTitle = @"通知-subtitle";
    NSString *body = @"通知-body";
    NSInteger badge = 1;
    NSInteger timeInteval = 5;
    NSDictionary *userInfo = @{@"id":@"LOCAL_NOTIFY_SCHEDULE_ID"};
    
    if (@available(iOS 10.0, *)) {
        // 1.创建通知内容
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        [content setValue:@(YES) forKeyPath:@"shouldAlwaysAlertWhileAppIsForeground"];
        content.sound = [UNNotificationSound defaultSound];
        content.title = title;
        content.subtitle = subTitle;
        content.body = body;
        content.badge = @(badge);

        content.userInfo = userInfo;

        // 2.设置通知附件内容
        NSError *error = nil;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"logo_img_02@2x" ofType:@"png"];
        UNNotificationAttachment *att = [UNNotificationAttachment attachmentWithIdentifier:@"att1" URL:[NSURL fileURLWithPath:path] options:nil error:&error];
        if (error) {
            NSLog(@"attachment error %@", error);
        }
        content.attachments = @[att];
        content.launchImageName = @"icon_certification_status1@2x";
        // 2.设置声音
        UNNotificationSound *sound = [UNNotificationSound soundNamed:@"sound01.wav"];// [UNNotificationSound defaultSound];
        content.sound = sound;

        // 3.触发模式
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:timeInteval repeats:NO];

        // 4.设置UNNotificationRequest
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:LocalNotiReqIdentifer content:content trigger:trigger];

        //5.把通知加到UNUserNotificationCenter, 到指定触发点会被触发
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        }];

    } else {
    
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        
        // 1.设置触发时间（如果要立即触发，无需设置）
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
        
        // 2.设置通知标题
        localNotification.alertBody = title;
        
        // 3.设置通知动作按钮的标题
        localNotification.alertAction = @"查看";
        
        // 4.设置提醒的声音
        localNotification.soundName = @"sound01.wav";// UILocalNotificationDefaultSoundName;
        
        // 5.设置通知的 传递的userInfo
        localNotification.userInfo = userInfo;
        
        // 6.在规定的日期触发通知
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        // 6.立即触发一个通知
        //[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
}

- (void)cancelLocalNotificaitons {
    
    //! 取消一个特定的通知
    NSArray *notificaitons = [[UIApplication sharedApplication] scheduledLocalNotifications];
    //获取当前所有的本地通知
    if (!notificaitons || notificaitons.count <= 0) { return; }
    for (UILocalNotification *notify in notificaitons) {
        if ([[notify.userInfo objectForKey:@"id"] isEqualToString:@"LOCAL_NOTIFY_SCHEDULE_ID"]) {
            if (@available(iOS 10.0, *)) {
                [[UNUserNotificationCenter currentNotificationCenter] removePendingNotificationRequestsWithIdentifiers:@[LocalNotiReqIdentifer]];
            } else {
                [[UIApplication sharedApplication] cancelLocalNotification:notify];
            }
            break;
        }
    }
    //! 取消所有的本地通知
    //[[UIApplication sharedApplication] cancelAllLocalNotifications];
}

@end
