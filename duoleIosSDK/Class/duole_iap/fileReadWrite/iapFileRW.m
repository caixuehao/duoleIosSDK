//
//  iapFileRW.m
//  duoleIosSDK
//
//  Created by cxh on 16/8/3.
//  Copyright © 2016年 cxh. All rights reserved.
//

#import "iapFileRW.h"
#import "Macro.h"
#import <StoreKit/StoreKit.h>

@implementation iapFileRW{
    NSMutableDictionary* plistDataDIC;
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

//获取消息字符串
-(NSString*)getMessageStr:(NSString*)key{
    return [[plistDataDIC objectForKey:@"message"] objectForKey:key];
}

//获取丢失订单的收据
-(NSMutableArray*)GetLostOrders{
    // 获取Documents目录路径
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    NSMutableArray* LostOrders_arr;
    if ([filemgr fileExistsAtPath: [self getPath] ] == NO){
        NSLog(@"文件不存在");
        //创建文件夹
        NSString* CatalogPath = [[self getPath] stringByDeletingLastPathComponent];
        [[NSFileManager defaultManager] createDirectoryAtPath:CatalogPath withIntermediateDirectories:YES attributes:nil error:nil];
        LostOrders_arr = [[NSMutableArray alloc] init];
        [LostOrders_arr writeToFile:[self getPath] atomically:YES];
    }else{
        LostOrders_arr = [[NSMutableArray alloc] initWithContentsOfFile:[self getPath]];
    }
    return LostOrders_arr;
}


//把收据写入本地
-(void)WiretReceipt:(SKPaymentTransaction*)transaction{
    
    NSMutableArray* arr = [self GetLostOrders];

    NSString* receipt = [transaction.transactionReceipt base64Encoding];
    
    [arr addObject:receipt];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:@"duole_ios_iap_receipt.plist"];
    [arr writeToFile:path atomically:YES];
    
    
    [duole_ios_iap_log WriteLog:@"保存收据"];
}

@end
