//
//  NotificationService.m
//  QiNotificationService
//
//  Created by wangdacheng on 2018/9/29.
//  Copyright © 2018年 dac. All rights reserved.
//

#import "NotificationService.h"
#import <AVFoundation/AVFoundation.h>

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    //// Modify the notification content here...
    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [ServiceExtension modified]", self.bestAttemptContent.title];
    
    // 注：为通知下拉手动展开时，可添加多个事件
    // UNNotificationActionOptions包含三个值UNNotificationActionOptionAuthenticationRequired、UNNotificationActionOptionDestructive、UNNotificationActionOptionForeground
    UNNotificationAction * actionA  =[UNNotificationAction actionWithIdentifier:@"ActionA" title:@"A_Required" options:UNNotificationActionOptionAuthenticationRequired];
    UNNotificationAction * actionB = [UNNotificationAction actionWithIdentifier:@"ActionB" title:@"B_Destructive" options:UNNotificationActionOptionDestructive];
    UNNotificationAction * actionC = [UNNotificationAction actionWithIdentifier:@"ActionC" title:@"C_Foreground" options:UNNotificationActionOptionForeground];
    UNTextInputNotificationAction * actionD = [UNTextInputNotificationAction actionWithIdentifier:@"ActionD"
                                                                                            title:@"D_InputDestructive"
                                                                                          options:UNNotificationActionOptionDestructive
                                                                             textInputButtonTitle:@"Send"
                                                                             textInputPlaceholder:@"input some words here ..."];
    NSMutableArray *actionArr = [[NSMutableArray alloc] initWithObjects:actionA, actionB, actionC, actionD, nil];
    if (actionArr.count) {
        UNNotificationCategory * notficationCategory = [UNNotificationCategory categoryWithIdentifier:@"QiShareCategoryIdentifier"
                                                                                              actions:actionArr
                                                                                    intentIdentifiers:@[@"ActionA",@"ActionB",@"ActionC",@"ActionD"]
                                                                                              options:UNNotificationCategoryOptionCustomDismissAction];
        [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithObject:notficationCategory]];
    }
    
    
    // 注：1.通知扩展功能须在aps串中设置字段"mutable-content":1； 2.多媒体的字段可以与appServer协议制定；
    self.bestAttemptContent.categoryIdentifier = @"QiShareCategoryIdentifier";
    
    NSDictionary *userInfo =  self.bestAttemptContent.userInfo;
    NSString *mediaUrl = [NSString stringWithFormat:@"%@", userInfo[@"media"][@"url"]];
    if (!mediaUrl.length) {
        self.contentHandler(self.bestAttemptContent);
    } else {
        [self loadAttachmentForUrlString:mediaUrl withType:userInfo[@"media"][@"type"] completionHandle:^(UNNotificationAttachment *attach) {
            
            if (attach) {
                self.bestAttemptContent.attachments = [NSArray arrayWithObject:attach];
            }
            self.contentHandler(self.bestAttemptContent);
        }];
    }
}

- (void)loadAttachmentForUrlString:(NSString *)urlStr withType:(NSString *)type completionHandle:(void(^)(UNNotificationAttachment *attach))completionHandler
{
    __block UNNotificationAttachment *attachment = nil;
    NSURL *attachmentURL = [NSURL URLWithString:urlStr];
    NSString *fileExt = [self fileExtensionForMediaType:type];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session downloadTaskWithURL:attachmentURL completionHandler:^(NSURL *temporaryFileLocation, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"加载多媒体失败 %@", error.localizedDescription);
        } else {
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSURL *localURL = [NSURL fileURLWithPath:[temporaryFileLocation.path stringByAppendingString:fileExt]];
            [fileManager moveItemAtURL:temporaryFileLocation toURL:localURL error:&error];
            
            // 自定义推送UI需要
            NSMutableDictionary * dict = [self.bestAttemptContent.userInfo mutableCopy];
            [dict setObject:[NSData dataWithContentsOfURL:localURL] forKey:@"image"];
            self.bestAttemptContent.userInfo = dict;
            
            NSError *attachmentError = nil;
            attachment = [UNNotificationAttachment attachmentWithIdentifier:@"" URL:localURL options:nil error:&attachmentError];
            if (attachmentError) {
                NSLog(@"%@", attachmentError.localizedDescription);
            }
        }
        completionHandler(attachment);
    }] resume];
}

- (NSString *)fileExtensionForMediaType:(NSString *)type {
    NSString *ext = type;
    if ([type isEqualToString:@"image"]) {
        ext = @"jpg";
    }
    if ([type isEqualToString:@"video"]) {
        ext = @"mp4";
    }
    if ([type isEqualToString:@"audio"]) {
        ext = @"mp3";
    }
    return [@"." stringByAppendingString:ext];
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
