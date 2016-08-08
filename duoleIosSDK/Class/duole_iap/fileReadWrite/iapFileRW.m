//
//  iapFileRW.m
//  duoleIosSDK
//
//  Created by cxh on 16/8/3.
//  Copyright © 2016年 cxh. All rights reserved.
//

#import "iapFileRW.h"
#import "Macro.h"
#import "duole_log.h"

@implementation iapFileRW{
    NSMutableDictionary* plistDataDIC;
}

+(instancetype)share{
    return [[iapFileRW alloc] init];
}

-(instancetype)init{
    self = [super init];
    if (self) {
        NSString* path = [[NSBundle mainBundle] pathForResource:@"duole_iap" ofType:@"plist"];
        plistDataDIC = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
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
//---------------读------------------

//读取默认的服务器地址
-(NSString*)getURL{
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

//---------------写------------------
//把收据写入本地
-(void)wiretReceipt:(SKPaymentTransaction*)transaction{
    NSMutableArray* arr = [self getReceipts];
    
    NSString* protocolInfo = transaction.payment.applicationUsername;
    NSString* receipt = [transaction.transactionReceipt base64Encoding];
    NSDictionary* dic = @{@"receipt":receipt,
                          @"protocolInfo":protocolInfo};
    [arr addObject:dic];
    
    
    [arr writeToFile:[self getPath] atomically:YES];
    [duole_log WriteLog:@"保存收据"];
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
