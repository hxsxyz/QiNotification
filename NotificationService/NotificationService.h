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


//// apsModel示例
/*
 特殊说明：
 1. APNS去掉alert、badge、sound字段实现静默推送，增加增加字段"content-available":1，也可以在后台做一些事情。
 2. mutable-content这个键值为1，说明此条推送可以被 Service Extension 进行更改。
 */

/**
 {"aps":{"alert":{"title":"通知的title","subtitle":"通知的subtitle","body":"通知的body","title-loc-key":"TITLE_LOC_KEY","title-loc-args":["t_01","t_02"],"loc-key":"LOC_KEY","loc-args":["l_01","l_02"]},"sound":"sound01.wav","badge":1,"mutable-content":1,"category": "realtime"},"msgid":"123"}
 */

/**
 {"aps":{"alert":{"title":"Title...","subtitle":"Subtitle...","body":"Body..."},"sound":"default","badge": 1,"mutable-content": 1,"category": "realtime",},"msgid":"123","media":{"type":"image","url":"https://www.fotor.com/images2/features/photo_effects/e_bw.jpg"}}
 */
