//
//  FJThirdPayFileRW.m
//  duoleIosSDK
//
//  Created by duole on 17/2/13.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "FJThirdPayFileRW.h"
#import "Macro.h"
#import "duole_log.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>
#import "FJThirdPaySendReceipt.h"

@implementation FJThirdPayFileRW{
    NSMutableDictionary* plistDataDIC;
    NSString *trans_id;//风际服务器返回的订单id

}

+(instancetype)share{
    return [[FJThirdPayFileRW alloc] init];
}


-(instancetype)init{
    self = [super init];
    if (self) {
        NSString* path = [[NSBundle mainBundle] pathForResource:@"duole_iap" ofType:@"plist"];
        plistDataDIC = [[[NSMutableDictionary alloc] initWithContentsOfFile:path] objectForKey:@"FJThirdPay"];
        trans_id = [[NSString alloc] init];
    }
    return self;
}
//路径
-(NSString*)getPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [paths objectAtIndex:0];
    plistPath = [plistPath stringByAppendingPathComponent:Duole_IOSSDK_iapReceipt_PATH];
    
    return plistPath;
}
-(NSString*)getOrderIdPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [paths objectAtIndex:0];
    plistPath = [plistPath stringByAppendingPathComponent:Duole_IOSSDK_orderId_PATH];
    
    return plistPath;
}

//---------------读------------------

-(NSDictionary *)getProtocol{
    return [plistDataDIC objectForKey:@"Protocol"];
}

//读取服务器地址
-(NSString*)getURL{
    return [[plistDataDIC objectForKey:@"Protocol"] objectForKey:@"URL"];
}
//获取正式的服务器地址
-(NSString* )getPayTypeURL{
    return [[plistDataDIC objectForKey:@"Protocol"] objectForKey:@"URL"];
}

//读取请求参数
-(NSMutableDictionary*)getProtocolParameters{
    return [[plistDataDIC objectForKey:@"Protocol"] objectForKey:@"main_dic"];
}
//获取消息字符串
-(NSString*)getMessageStr:(NSString*)key{
    return [[plistDataDIC objectForKey:@"message"] objectForKey:key];
}
//获取商品ID
-(NSDictionary*)getProducts{
    return [plistDataDIC objectForKey:@"ProductList"];
}

//获取收据
-(NSMutableArray*)getReceipts{
    
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    NSMutableArray* LostReceipts_arr;
    if ([filemgr fileExistsAtPath: [self getPath] ] == NO){
        NSLog(@"文件不存在");
        //创建文件夹
        NSString* CatalogPath = [[self getPath] stringByDeletingLastPathComponent];
        [[NSFileManager defaultManager] createDirectoryAtPath:CatalogPath withIntermediateDirectories:YES attributes:nil error:nil];
        LostReceipts_arr = [[NSMutableArray alloc] init];
        [LostReceipts_arr writeToFile:[self getPath] atomically:YES];
    }else{
        LostReceipts_arr = [[NSMutableArray alloc] initWithContentsOfFile:[self getPath]];
    }
    return LostReceipts_arr;
}

//获取收据
-(NSMutableArray*)getTransId{
    
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    NSMutableArray* LostTransId_arr;
    if ([filemgr fileExistsAtPath: [self getOrderIdPath] ] == NO){
        NSLog(@"文件不存在");
        //创建文件夹
        NSString* CatalogPath = [[self getPath] stringByDeletingLastPathComponent];
        [[NSFileManager defaultManager] createDirectoryAtPath:CatalogPath withIntermediateDirectories:YES attributes:nil error:nil];
        LostTransId_arr = [[NSMutableArray alloc] init];
        [LostTransId_arr writeToFile:[self getOrderIdPath] atomically:YES];
    }else{
        LostTransId_arr = [[NSMutableArray alloc] initWithContentsOfFile:[self getOrderIdPath]];
    }
    return LostTransId_arr;
}

//---------------写------------------
//把收据写入本地
-(void)wiretReceipt:(SKPaymentTransaction*)transaction{

    NSMutableArray* arr = [self getReceipts];
    
    NSString* protocolInfo = transaction.payment.applicationUsername;
    NSString* receipt = [transaction.transactionReceipt base64Encoding];
//    NSLog(@"transactionReceipt===%@",receipt);
    
    //获取返回的风际订单id，添加到收据中后删除
    NSMutableArray *trandIdArr = [self getTransId];
    NSString *transId = [trandIdArr objectAtIndex:0];
    [trandIdArr removeObjectAtIndex:0];
    [trandIdArr writeToFile:[self getOrderIdPath] atomically:YES];
    
    NSDictionary* dic = @{@"receipt":receipt,@"protocolInfo":protocolInfo,@"transId":transId};

    
    [arr addObject:dic];
    
    
    [arr writeToFile:[self getPath] atomically:YES];
    [duole_log WriteLog:@"保存收据"];
    
}

-(void )getOrderID:(NSDictionary*)dic{
    FJThirdPayFileRW* fileRw = [[FJThirdPayFileRW alloc] init];
    NSLog(@"dic==%@",dic);
    //开始发送
    NSLog(@"开始发送数据生成订单号");
    NSString *roleName = [dic objectForKey:@"roleName"];
    
    NSString *openID = [[NSString alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath1 = [paths objectAtIndex:0];
    NSString *path=[plistPath1 stringByAppendingPathComponent:@"duoleIosSdk/FJuserinfo.plist"];
    NSMutableArray *userArr = [[NSMutableArray alloc] initWithContentsOfFile:path];
    for (NSMutableDictionary *dic in userArr) {
        if ([[dic objectForKey:@"account"] isEqualToString:roleName]) {
            openID = [dic objectForKey:@"open_id"];
        }
    }
    //苹果支付:ios 谷歌官方支付 :google 第三方支付:other
    NSString *pay_type = [[self getProtocol] objectForKey:@"payType"];
    //发送地址
    NSString *payURL = [fileRw getURL];
    //服务器ID
    NSString *sid = [dic objectForKey:@"serverId"];
    //账号 ID 或 open_id
    NSString *uid = openID;
    //角色 ID 或者 char_id 如果没有角色传 uid
    NSString *cid = [dic objectForKey:@"roleId"];
    //渠道 ID
    NSString *channelid = [[self getProtocol] objectForKey:@"channelid"];
    //支付类型 CNY 人民币 USD 美元
    NSString *currency = @"CNY";
    //商品标示id
    NSString *productid = [dic objectForKey:@"productId"];
    //appID
    NSString *appid = [[self getProtocol] objectForKey:@"appid"];
    //秘钥public_key
    NSString *key = [[self getProtocol] objectForKey:@"key"];
    //支付金币
    int totalmoney = [[dic objectForKey:@"money"] intValue];
    
    NSString* sign = [self hmacSha1:key data:[NSString stringWithFormat:@"pay/get_order&appid=%@&channelid=%@&cid=%@&client_type=1&currency=%@&pay_type=%@&productid=%@&sid=%@&totalmoney=%i&%@",
                                 appid,channelid,cid,currency,pay_type,productid,sid,totalmoney,key]];
    NSString *bodyStr = [[NSString alloc] initWithFormat:@"appid=%@&channelid=%@&cid=%@&client_type=1&currency=%@&pay_type=%@&productid=%@&sid=%@&sign=%@&totalmoney=%i",
                         appid,channelid,cid,currency,pay_type,productid,sid,sign,totalmoney];
    NSString *URL_str = [payURL stringByAppendingString:@"pay/get_order"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_str]];
    request.HTTPMethod = @"POST";//请求方法
    request.timeoutInterval = 30.0;//设置请求超时为5秒
    request.HTTPBody = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary* dic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            if (error == nil) {
                int ret = [[dic objectForKey:@"rs"] intValue];
                if (ret == 0){
                    NSLog(@"订单号获取成功");
                    [duole_log WriteLog:@"订单号获取成功"];
                    trans_id = [dic objectForKey:@"trans_id"];
                    
                    NSMutableArray *arr = [self getTransId];
                    [arr insertObject:trans_id atIndex:0];
                    [arr writeToFile:[self getOrderIdPath] atomically:YES];
                    [duole_log WriteLog:@"保存风际订单号"];
                }
                else{
                    NSString *msg = [dic objectForKey:@"msg"];
                    NSLog(@"订单号获取失败");
                    [duole_log WriteLog:[NSString stringWithFormat:@"订单号获取失败,错误说明：%@",msg]];
                    return;
                }
            }
        }
    }] resume];
    
    
}

//hmacSha1加密
- (NSString*)hmacSha1:(NSString *)key data:(NSString *)data
{
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [data cStringUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    //NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH];
    NSString *hash;
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", cHMAC[i]];
    hash = output;
    
    return [hash lowercaseString];
    
}
//删除收据
-(void)removeReceipt{
    
    NSMutableArray* arr = [self getReceipts];
    if (arr.count == 0) return;
    
    [arr removeObjectAtIndex:0];
    [arr writeToFile:[self getPath] atomically:YES];
    

    
    [duole_log WriteLog:@"删除收据"];

    


}

@end
