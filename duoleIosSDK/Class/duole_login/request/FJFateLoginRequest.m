//
//  FJFateLoginRequest.m
//  duoleIosSDK
//
//  Created by duole on 17/2/9.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "FJFateLoginRequest.h"
#import "loginFileReadWrite.h"



@implementation FJFateLoginRequest{
    
    loginFileReadWrite *_loginFileData;
    
    NSString* loginURL;
    NSInteger cpId;
    NSInteger gameId;
    NSString* loginKey;
    NSString* appid;
}
-(instancetype)init{
    self = [super init];
    if (self) {
        _loginFileData = [loginFileReadWrite share];
        NSMutableDictionary* Dic =  [_loginFileData GetduoleIosLoginInfo];
        NSDictionary* dic = [Dic objectForKey:@"FJFateRequest"];
        //        NSLog(@"%@",dic);
        
        loginURL = [dic objectForKey:@"LoginURL"];//登陆地址
        cpId = [[dic objectForKey:@"CpID"] integerValue];//合作方id
        gameId = [[dic objectForKey:@"GameID"] integerValue];//游戏id
        loginKey = [dic objectForKey:@"Key"];//登陆密匙
        appid = [dic objectForKey:@"appid"];//应用id
    }
    return self;
}

//快速登录
-(void)QuickLogin{
//    NSString *sign  = [self md5:[DevieceUUID stringByAppendingString:loginKey]];
//    NSString* URL_str =  [[NSString alloc] initWithFormat:@"%@quick_register.php?device=%@&cp_id=%lu&game_id=%lu&sign=%@",loginURL,DevieceUUID,cpId,gameId,sign];
//    [[[NSURLSession sharedSession] dataTaskWithRequest:[self getRequestWithURL:URL_str] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if (error == nil) {
//            NSDictionary* dic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
//            //如果解析错误
//            if (error == nil) {
//                int ret = [[dic objectForKey:@"ret"] intValue];
//                if (ret == 0){
//                    
//                    //解析成功也返回成功
//                    NSString *quick_id = [[dic objectForKey:@"data"] objectForKey:@"quick_id"];
//                    [_loginFileData AddOBjectAtName:quick_id PassWord:@"" UserType:1];//保存到本地
//                    //然后调用登录
//                    [self Login:quick_id Password:@"" isNewAccount:YES];
//                    
//                }
//                else{
//                    NSString *msg = [dic objectForKey:@"msg"];
//                    [self.delegate loginFail:msg];return;
//                }
//            }
//        }
//        if(error)[self.delegate loginFail:[error localizedDescription]];
//    }] resume];
    NSString *password = @"123456";
    NSString *account = [DevieceUUID substringToIndex:8];
    NSString* sign = [self hmacSha1:loginKey data:[NSString stringWithFormat:@"user/register&appid=%@&channel=2&password=%@&username=%@&%@",appid,password,account,loginKey]];
    //    NSString *URL_str = [[NSString alloc] initWithFormat:@"%@register.php?user_name=%@&passwd=%@&cp_id=%lu&game_id=%lu&device=%@&sign=%@",loginURL,account,password,cpId,gameId,DevieceUUID,sign] ;
    NSString *bodyStr = [[NSString alloc] initWithFormat:@"appid=%@&channel=2&password=%@&sign=%@&username=%@",appid,password,sign,account];
    
    NSString *URL_str = [loginURL stringByAppendingString:@"user/register"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_str]];
    request.HTTPMethod = @"POST";//请求方法
    request.timeoutInterval = 5.0;//设置请求超时为5秒
    request.HTTPBody = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary* dic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            if (error == nil) {
                int ret = [[dic objectForKey:@"rs"] intValue];
                if (ret == 0){
                    [_loginFileData AddOBjectAtName:account PassWord:password UserType:1];
                    //调用登陆
                    [self Login:account Password:password isNewAccount:YES];
                }
                else{
                    NSString *msg = [dic objectForKey:@"msg"];
                    [self.delegate loginFail:msg];
                    return;
                }
            }
        }
        if(error)[self.delegate loginFail:[error localizedDescription]];
    }] resume];
    
    
}

//登陆 帐号 密码 是否是新账号
-(void)Login:(NSString*)account Password:(NSString*)password isNewAccount:(BOOL)isNewAccount{
    //检查账号类型
    NSMutableDictionary* userinfo = [_loginFileData readUserInfo];
    NSMutableArray* user_arr = [userinfo objectForKey:@"用户数组"];
    
    int usertype = 0;
    //判断是否是临时账号
    for (NSMutableDictionary *dic in user_arr) {
        if ([account isEqualToString:[dic objectForKey:@"name"]]) {
            int i = [[dic objectForKey:@"userType"] intValue];
            if(i == 1){
                usertype = 1;
                password = @"123456";
//                NSString *sign = [self md5:[NSString stringWithFormat:@"%@%@%@",account,DevieceUUID,loginKey]];
//                NSString *URL_str =  [[NSString alloc] initWithFormat:@"%@quick_login.php?quick_id=%@&device=%@&cp_id=%lu&game_id=%lu&sign=%@",loginURL,account,DevieceUUID,cpId,gameId,sign] ;
//                [[[NSURLSession sharedSession] dataTaskWithRequest:[self getRequestWithURL:URL_str] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//                    if (error == nil) {
//                        NSDictionary* dic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
//                        if (error == nil) {
//                            int ret = [[dic objectForKey:@"ret"] intValue];
//                            if (ret == 0){
//                                //解析成功保存到本地
//                                [_loginFileData AddOBjectAtName:account PassWord:password UserType:1];
//                                
//                                NSMutableDictionary* newdic = [[NSMutableDictionary alloc] initWithDictionary:[dic objectForKey:@"data"]];
//                                [newdic setObject:account forKey:@"account"];
//                                if (isNewAccount) [newdic setObject:@(isNewAccount) forKey:@"newAccount"];
//                                [self.delegate loginSuccess:newdic];
//                                
//                            }
//                            else{
//                                NSString *msg = [dic objectForKey:@"msg"];
//                                [self.delegate loginFail:msg];return;
//                            }
//                        }
//                    }
//                    if(error)[self.delegate loginFail:[error localizedDescription]];
//                }] resume];
                
//                return;
                
            } if (i == 0) {
                //正常账号
                usertype = 0;
                //赋值密码
                if (password.length == 0) {
                    password = [dic objectForKey:@"pass"];
                }
                
            }
        }
    }
    
    //---------------正常账号登录-------------------
    //别忘了将平台号改成正常账号登录的
    NSString *sign = [self hmacSha1:loginKey data:[NSString stringWithFormat:@"user/login&appid=%@&password=%@&username=%@&%@",appid,[self md5:password],account,loginKey]];
//    NSString *URL_str = [[NSString alloc] initWithFormat:@"%@login.php?user_name=%@&passwd=%@&cp_id=%lu&game_id=%lu&sign=%@",loginURL,account,password,cpId,gameId,sign] ;
    NSString *bodyStr = [[NSString alloc] initWithFormat:@"appid=%@&password=%@&sign=%@&username=%@",appid,[self md5:password],sign,account];
    
    NSString *URL_str = [loginURL stringByAppendingString:@"user/login"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_str]];
    request.HTTPMethod = @"POST";//请求方法
    request.timeoutInterval = 5.0;//设置请求超时为5秒
    request.HTTPBody = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary* dic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            if (error == nil) {
                int ret = [[dic objectForKey:@"rs"] intValue];
                if (ret == 0){
                    //解析成功保存到本地
                    [_loginFileData AddOBjectAtName:account PassWord:password UserType:usertype];
                    
                    NSString *open_id = [NSString stringWithFormat:@"%@",[dic objectForKey:@"open_id"]];
                    
                    NSMutableDictionary* newdic = [[NSMutableDictionary alloc] initWithDictionary:@{@"open_id":open_id,
                                                                                                    @"token":[dic objectForKey:@"token"]
                                                                                                    }];
                    
                    [newdic setObject:account forKey:@"account"];
                    if (isNewAccount)[newdic setObject:@(isNewAccount) forKey:@"newAccount"];
                    [self.delegate loginSuccess:newdic];
                    
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *plistPath1 = [paths objectAtIndex:0];
                    NSString *path=[plistPath1 stringByAppendingPathComponent:@"duoleIosSdk/FJuserinfo.plist"];
                    NSMutableArray *userArr = [[NSMutableArray alloc] initWithContentsOfFile:path];
                    if (userArr == nil) {
                        userArr = [[NSMutableArray alloc] init];
                        BOOL bl = [userArr writeToFile:path atomically:YES];
                        if (bl == NO) NSLog(@"文件写入失败");
                    }else{
                        NSMutableDictionary *dictemp = [[NSMutableDictionary alloc] init];
                        for (NSMutableDictionary *dic in userArr) {
                            if ([[dic objectForKey:@"account"] isEqualToString:account]) {
                                dictemp = dic;
                            }
                        }
                        [userArr removeObject:dictemp];
                    }
                    [userArr insertObject:newdic atIndex:0];
                    BOOL bl = [userArr writeToFile:path atomically:YES];
                    if (bl == NO) NSLog(@"文件写入失败");
                    
                }
                else{
                    NSString *msg = [dic objectForKey:@"msg"];
                    [self.delegate loginFail:msg];return;
                }
            }
        }
        if(error)[self.delegate loginFail:[error localizedDescription]];
    }] resume];
}

//注册        帐号 密码
-(void)Register:(NSString*)account Password:(NSString*)password{
    
    NSString* sign = [self hmacSha1:loginKey data:[NSString stringWithFormat:@"user/register&appid=%@&password=%@&username=%@&%@",appid,password,account,loginKey]];
//    NSString *URL_str = [[NSString alloc] initWithFormat:@"%@register.php?user_name=%@&passwd=%@&cp_id=%lu&game_id=%lu&device=%@&sign=%@",loginURL,account,password,cpId,gameId,DevieceUUID,sign] ;
    NSString *bodyStr = [[NSString alloc] initWithFormat:@"appid=%@&password=%@&sign=%@&username=%@",appid,password,sign,account];

    NSString *URL_str = [loginURL stringByAppendingString:@"user/register"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_str]];
    request.HTTPMethod = @"POST";//请求方法
    request.timeoutInterval = 5.0;//设置请求超时为5秒
    request.HTTPBody = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary* dic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            if (error == nil) {
                int ret = [[dic objectForKey:@"rs"] intValue];
                if (ret == 0){
                    
                    //调用登陆
                    [self Login:account Password:password isNewAccount:YES];
                }
                else{
                    NSString *msg = [dic objectForKey:@"msg"];
                    [self.delegate loginFail:msg];
                    return;
                }
            }
        }
        if(error)[self.delegate loginFail:[error localizedDescription]];
    }] resume];
}

//绑定        临时账号 帐号 密码
-(void)Bound:(NSString*)quick_id account:(NSString*)account Password:(NSString*)password{
    
    NSString *open_id = [[NSString alloc] init];
    NSString *token = [[NSString alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath1 = [paths objectAtIndex:0];
    NSString *path=[plistPath1 stringByAppendingPathComponent:@"duoleIosSdk/FJuserinfo.plist"];
    NSMutableArray *userArr = [[NSMutableArray alloc] initWithContentsOfFile:path];
    for (NSMutableDictionary *dic in userArr) {
        if ([[dic objectForKey:@"account"] isEqualToString:[DevieceUUID substringToIndex:8]]) {
            open_id = [dic objectForKey:@"open_id"];
            token = [dic objectForKey:@"token"];
        }
    }
    
    
    NSString* sign = [self hmacSha1:loginKey data:[NSString stringWithFormat:@"user/bind_account&appid=%@&open_id=%@&password=%@&token=%@&username=%@&%@",appid,open_id,password,token,account,loginKey]];
    NSString *bodyStr =  [[NSString alloc] initWithFormat:@"appid=%@&open_id=%@&password=%@&sign=%@&token=%@&username=%@",appid,open_id,password,sign,token,account];
    NSString *URL_str = [loginURL stringByAppendingString:@"user/bind_account"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_str]];
    request.HTTPMethod = @"POST";//请求方法
    request.timeoutInterval = 5.0;//设置请求超时为5秒
    request.HTTPBody = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary* dic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            if (error == nil) {
                int ret = [[dic objectForKey:@"rs"] intValue];
                if (ret == 0){
                    
                    //删除临时账号
                    [_loginFileData removeOBjectAtName:[DevieceUUID substringToIndex:8]];
                    [_loginFileData AddOBjectAtName:account PassWord:password UserType:0];
                    //调用登陆
                    [self Login:account Password:password isNewAccount:YES];
                }
                else{
                    NSString *msg = [dic objectForKey:@"msg"];
                    [self.delegate loginFail:msg];return;
                }
            }
        }
        if(error)[self.delegate loginFail:[error localizedDescription]];
    }] resume];
}

//修改密码   账号  旧密码 新密码
-(void)ChangPassword:(NSString*)account oldPassword:(NSString*)oldPassword  newPassword:(NSString*)newPassword{
    NSString *openID = [[NSString alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath1 = [paths objectAtIndex:0];
    NSString *path=[plistPath1 stringByAppendingPathComponent:@"duoleIosSdk/FJuserinfo.plist"];
    NSMutableArray *userArr = [[NSMutableArray alloc] initWithContentsOfFile:path];
    for (NSMutableDictionary *dic in userArr) {
        if ([[dic objectForKey:@"account"] isEqualToString:account]) {
            openID = [dic objectForKey:@"open_id"];
        }
    }
    
    NSString* sign = [self hmacSha1:loginKey data:[NSString stringWithFormat:@"user/change_pass&appid=%@&new_password=%@&old_password=%@&open_id=%@&%@",appid,newPassword,[self md5:oldPassword],openID,loginKey]];
//    NSString *URL_str =      [[NSString alloc] initWithFormat:@"%@change_passwd.php?user_name=%@&old_passwd=%@&new_passwd=%@&cp_id=%lu&game_id=%lu&sign=%@",loginURL,account,oldPassword,newPassword,cpId,gameId,sign] ;
    NSString *bodyStr = [[NSString alloc] initWithFormat:@"appid=%@&new_password=%@&old_password=%@&open_id=%@&sign=%@",appid,newPassword,[self md5:oldPassword],openID,sign];
    
    NSString *URL_str = [loginURL stringByAppendingString:@"user/change_pass"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_str]];
    request.HTTPMethod = @"POST";//请求方法
    request.timeoutInterval = 5.0;//设置请求超时为5秒
    request.HTTPBody = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary* dic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            if (error == nil) {
                int ret = [[dic objectForKey:@"rs"] intValue];
                if (ret == 0){
                    //调用登陆
                    [self Login:account Password:newPassword isNewAccount:NO];
                }
                else{
                    NSString *msg = [dic objectForKey:@"msg"];
                    [self.delegate loginFail:msg];return;
                }
            }
        }
        if(error)[self.delegate loginFail:[error localizedDescription]];
    }] resume];
}

@end
