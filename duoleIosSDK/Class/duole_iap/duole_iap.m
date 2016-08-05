//
//  duole_iap.m
//  duoleIosSDK
//
//  Created by cxh on 16/8/2.
//  Copyright © 2016年 cxh. All rights reserved.
//

#import "duole_iap.h"
#import "duole_log.h"

static duole_iap* duole_iap_share;

@implementation duole_iap{
    NSMutableDictionary *userInfo;//存放用户数据
    NSDictionary *message_dic;//存放消息映射字典
    NSDictionary *ProductList;//商品映射字典
    NSString* URL;//存放通知服务器地址的地方
    NSDictionary* Protocol_main_dic;//存放协议的字典
    
    BOOL initBl;//商品是否初始化成功.
}
+(instancetype)share{
    if (duole_iap_share == NULL) {
        duole_iap_share = [duole_iap init];
    }
    return duole_iap_share;
}

/**
 *  初始化
 *
 *  @param userInfoDIC  用户信息
 */
-(void)InitUserInfo:(NSDictionary*) userInfoDIC{
    NSLog(@"支付2.0.0 整理");
    
    userInfo = [[NSMutableDictionary alloc] initWithDictionary:userInfoDIC];
    initBl = NO;
    NSLog(@"%@",userInfo);
    //加日志
    NSString* str = @"初始化支付。初始化信息:";
    for (NSString* key in userInfoDIC) {
        if ([key isEqualToString:@"key1"] == NO) {
            str = [str stringByAppendingString:[NSString stringWithFormat:@" %@:%@ ",key,[userInfoDIC objectForKey:key]]];
        }
    }
    [duole_log WriteLog:str];
    //end
    
 
    
}



@end
