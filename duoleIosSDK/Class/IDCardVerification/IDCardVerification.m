//
//  IDCardVerification.m
//  duoleIosSDK
//
//  Created by cxh on 17/5/2.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "IDCardVerification.h"
static IDCardVerification *IDCardVerificationShare;
@implementation IDCardVerification{
    UIView* mainView;
    UITextField* idcardTF;
    UILabel* tipLabel;
}

+(instancetype)share{
    if (IDCardVerificationShare == nil) {
        IDCardVerificationShare = [[IDCardVerification alloc] init];
    }
    return IDCardVerificationShare;
}
-(instancetype)init{
    if (self = [super init]) {
        self.status = IDCardStatusNoInit;
    }
    return self;
}

-(void)setUserId:(NSString*)userid appid:(NSString*)appid complete:(void (^)(NSString* path))handler{
    
}
-(void)show{
    if (mainView) {
        [self back];
    }
    
    mainView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [mainView setBackgroundColor:[UIColor whiteColor]];
    [[UIApplication sharedApplication].keyWindow addSubview:mainView];
    

    UIButton* backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 80, 30)];
    [backBtn setTitle:@"退出" forState:UIControlStateNormal];
    [backBtn setBackgroundColor:[UIColor yellowColor]];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchDown];
    [mainView addSubview:backBtn];
    
    idcardTF = [[UITextField alloc] initWithFrame:CGRectMake(10, 50, mainView.bounds.size.width -20, 50)];
    idcardTF.backgroundColor = [[UIColor alloc] initWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1];
    [idcardTF.layer setCornerRadius:5.0];//圆角大小
    idcardTF.returnKeyType = UIReturnKeyGo;
    [mainView addSubview:idcardTF];
    
    tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 105, mainView.bounds.size.width -20, 20)];
    tipLabel.textColor = [UIColor redColor];
    tipLabel.text = @"按时大法师";
    [mainView addSubview:tipLabel];
    
    UIButton* okbtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 130, mainView.bounds.size.width -20, 40)];
    [okbtn setTitle:@"验证" forState:UIControlStateNormal];
    [okbtn setBackgroundColor:[UIColor yellowColor]];
    [okbtn addTarget:self action:@selector(verification) forControlEvents:UIControlEventTouchDown];
    [mainView addSubview:okbtn];
    
}


#pragma action
-(void)back{
    [mainView removeFromSuperview];
    tipLabel = NULL;
    idcardTF = NULL;
    mainView = NULL;
  
}


-(void)verification{
    tipLabel.text = @"";
    if ([self validateIDCardNumber:idcardTF.text]) {
        //验证成功
        NSLog(@"success");
        if ([self isAdult]) {
            NSLog(@"成人");
        }else{
            NSLog(@"未成年");
        }
    }else{
        NSLog(@"error");
         if(tipLabel.text.length == 0)tipLabel.text = @"身份证填写不正确，请检查。";
    }
}
-(BOOL)isAdult{
    NSCalendar * cal=[NSCalendar currentCalendar];
    NSUInteger unitFlags=NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit;
    NSDateComponents * conponent= [cal components:unitFlags fromDate:[NSDate date]];
    NSInteger nowyear=[conponent year];
    NSInteger nowmonth=[conponent month];
    NSInteger nowday=[conponent day];
    
    
    NSInteger useryear;
    NSInteger usermonth;
    NSInteger userday;
    if (idcardTF.text.length == 15) {
        useryear = [[NSString stringWithFormat:@"19%@",[idcardTF.text substringWithRange:NSMakeRange(6, 2)]] integerValue];
        usermonth = [[idcardTF.text substringWithRange:NSMakeRange(8, 2)] integerValue];
        userday = [[idcardTF.text substringWithRange:NSMakeRange(10,2)] integerValue];
    }else{
        useryear = [[idcardTF.text substringWithRange:NSMakeRange(6, 4)] integerValue];
        usermonth = [[idcardTF.text substringWithRange:NSMakeRange(10, 2)] integerValue];
        userday = [[idcardTF.text substringWithRange:NSMakeRange(12,2)] integerValue];
    }
    
    
    if ((nowyear - useryear)>18) {
        return YES;
    }else if((nowyear - useryear)<18){
        return NO;
    }else{
        if(nowmonth>useryear){
            return YES;
        }else if(useryear>nowmonth){
            return NO;
        }else{
            if (nowday>=userday) {
                return YES;
            }else{
                return NO;
            }
        }
    }
    
    return NO;
}



- (BOOL)validateIDCardNumber:(NSString *)value
{
    
    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    int length = 0;
    
    if (!value) {
        return NO;
    }
    else {
        length = (int)value.length;
        
        if (length !=15 && length !=18) {
            tipLabel.text = @"身份证位数不正确";
            return NO;
        }
    }
    // 省份代码
    NSArray *areasArray =@[@"11",@"12", @"13",@"14", @"15",@"21", @"22",@"23", @"31",@"32", @"33",@"34", @"35",@"36", @"37",@"41",@"42",@"43", @"44",@"45", @"46",@"50", @"51",@"52", @"53",@"54", @"61",@"62", @"63",@"64", @"65",@"71", @"81",@"82", @"91"];
    
    NSString *valueStart2 = [value substringToIndex:2];
    
    BOOL areaFlag =NO;
    
    for (NSString *areaCode in areasArray) {
        
        if ([areaCode isEqualToString:valueStart2]) {
            areaFlag =YES;
            break;
        }
    }
    
    if (!areaFlag) {
        return NO;
    }
    
    
    NSRegularExpression *regularExpression;
    NSUInteger numberofMatch;
    int year =0;
    switch (length) {
        case 15:{
            year = [value substringWithRange:NSMakeRange(6,2)].intValue +1900;
            if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$"
                                                                        options:NSRegularExpressionCaseInsensitive
                                                                          error:nil];//测试出生日期的合法性
            }else {
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$"
                                                                        options:NSRegularExpressionCaseInsensitive
                                                                          error:nil];//测试出生日期的合法性
            }
            numberofMatch = [regularExpression numberOfMatchesInString:value
                                                               options:NSMatchingReportProgress
                                                                 range:NSMakeRange(0, value.length)];
            
            if(numberofMatch >0) {
                
                return YES;
            }else {
                return NO;
            }
        }
        case 18:
            year = [value substringWithRange:NSMakeRange(6,4)].intValue;
            if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}((19[0-9]{2})|(2[0-9]{3}))((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}[0-9Xx]$"
                                                                        options:NSRegularExpressionCaseInsensitive
                                                                          error:nil];//测试出生日期的合法性
            }else {
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}((19[0-9]{2})|(2[0-9]{3}))((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}[0-9Xx]$"
                                                                        options:NSRegularExpressionCaseInsensitive
                                                                          error:nil];//测试出生日期的合法性
            }
            numberofMatch = [regularExpression numberOfMatchesInString:value
                                                               options:NSMatchingReportProgress
                                                                 range:NSMakeRange(0, value.length)];
            
            if(numberofMatch >0) {
                
                int S = ([value substringWithRange:NSMakeRange(0,1)].intValue + [value substringWithRange:NSMakeRange(10,1)].intValue) *7 + ([value substringWithRange:NSMakeRange(1,1)].intValue + [value substringWithRange:NSMakeRange(11,1)].intValue) *9 + ([value substringWithRange:NSMakeRange(2,1)].intValue + [value substringWithRange:NSMakeRange(12,1)].intValue) *10 + ([value substringWithRange:NSMakeRange(3,1)].intValue + [value substringWithRange:NSMakeRange(13,1)].intValue) *5 + ([value substringWithRange:NSMakeRange(4,1)].intValue + [value substringWithRange:NSMakeRange(14,1)].intValue) *8 + ([value substringWithRange:NSMakeRange(5,1)].intValue + [value substringWithRange:NSMakeRange(15,1)].intValue) *4 + ([value substringWithRange:NSMakeRange(6,1)].intValue + [value substringWithRange:NSMakeRange(16,1)].intValue) *2 + [value substringWithRange:NSMakeRange(7,1)].intValue *1 + [value substringWithRange:NSMakeRange(8,1)].intValue *6 + [value substringWithRange:NSMakeRange(9,1)].intValue *3;
                
                int Y = S %11;
                
                NSString *M =@"F";
                
                NSString *JYM =@"10X98765432";
                
                M = [JYM substringWithRange:NSMakeRange(Y,1)];// 判断校验位
                
                if ([M isEqualToString:[value substringWithRange:NSMakeRange(17,1)]]) {
                    return YES;// 检测ID的校验位
                }else {
                    return NO;
                }
            }else {
                
                return NO;
            }
        default:
            return NO;
    }
}
@end
