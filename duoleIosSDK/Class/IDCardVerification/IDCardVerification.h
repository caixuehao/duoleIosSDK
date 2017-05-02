//
//  IDCardVerification.h
//  duoleIosSDK
//
//  Created by cxh on 17/5/2.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,IDCardStatus){
    IDCardStatusNoInit = 0,//没初始化
    IDCardStatusNoVerification = 1, //没验证
    IDCardStatusUnderage = 2,//未成年人
    IDCardStatusAdult = 3//成人
};

@interface IDCardVerification : NSObject


/**
 *  身份证验证状态
 */
@property(nonatomic,assign)IDCardStatus status;


+(instancetype)share;


/**
 *  初始化(参数待定)
 */
-(void)setUserId:(NSString*)userid appid:(NSString*)appid complete:(void (^)(NSString* path))handler;

/**
 *  显示验证视图
 */
-(void)show;

@end
