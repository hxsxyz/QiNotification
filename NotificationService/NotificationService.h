//
//  NotificationService.h
//  NotificationService
//
//  Created by wangdacheng on 2018/9/29.
//  Copyright © 2018年 dac. All rights reserved.
//

#import <UserNotifications/UserNotifications.h>

@interface NotificationService : UNNotificationServiceExtension

@end



/**
  {"aps":{"alert":{"title":"Title...","subtitle":"Subtitle...","body":"Body..."},"sound":"default","badge": 1,"mutable-content": 1,"category": "realtime",},"msgid":"123","media":{"type":"image","url":"https://www.fotor.com/images2/features/photo_effects/e_bw.jpg"}}
 */
