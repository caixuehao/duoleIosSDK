//
//  GameLoginRequest.m
//  duoleIosSDK
//
//  Created by cxh on 16/7/27.
//  Copyright © 2016年 cxh. All rights reserved.
//

#import "GameLoginRequest.h"
#import <CommonCrypto/CommonDigest.h>

@implementation GameLoginRequest

//md5加密
- (NSString *)md5:(NSString *)str
{
    const char *original_str = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(original_str, (CC_LONG)strlen(original_str), result);
    
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

//请求合成
-(NSMutableURLRequest*)getRequestWithURL:(NSString*)url{
    
//    NSRange range = [url rangeOfString:@"?"];
//    NSString* uslStr = [url substringToIndex:range.location];
//    NSString* argsStr = [url substringFromIndex:range.location+range.length];
//    NSLog(@"%@",url);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";//请求方法
    //request.timeoutInterval=5.0;//设置请求超时为5秒
   // request.HTTPBody = [argsStr dataUsingEncoding:NSUTF8StringEncoding];
    return request;
}
@end
