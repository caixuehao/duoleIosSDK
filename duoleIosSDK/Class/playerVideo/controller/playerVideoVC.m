//
//  playerVideoVC.m
//  duoleIosSDK
//
//  Created by cxh on 16/8/17.
//  Copyright © 2016年 cxh. All rights reserved.
//

#import "playerVideoVC.h"
#import <AVFoundation/AVFoundation.h>
#import "CusNavViewController.h"
#define isIos7System [[[UIDevice currentDevice] systemVersion] floatValue] <= 7.0

playerVideoVC* playVideo;

@interface playerVideoVC()
@property(nonatomic,strong) NSString* path;
@property(nonatomic,assign) BOOL isFisttPlay;
@property(nonatomic,strong) AVPlayer *player;
@end

@implementation playerVideoVC{

}

+(void)playVideo:(NSString*)path{
    if (playVideo == NULL) {
        //强制横屏
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeLeft] forKey:@"orientation"];
        
        playVideo = [[playerVideoVC alloc] initWithPath:path];
        
        UIViewController* rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        rootVC.modalPresentationStyle = UIModalPresentationCurrentContext;
        [rootVC presentViewController:playVideo animated:YES completion:^{}];
    }
}

-(instancetype)initWithPath:(NSString*)path{
    self = [super init];
    if (self) {
        _path = path;
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        
        _isFisttPlay = ![[NSUserDefaults standardUserDefaults] boolForKey:@"duolePlayVideo"];
        if (_isFisttPlay == YES) {
            [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"duolePlayVideo"];
        }
    }
    return self;
}


- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

#pragma UIViewControllerDelegate

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = YES;
}

-(void)viewDidDisappear {
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView* image = [[UIImageView alloc] initWithFrame:self.view.bounds];
    image.image = [UIImage imageNamed:@"3123.jpg"];
    [self.view addSubview:image];
    
    NSURL* url = [NSURL fileURLWithPath:_path];
    _player = [[AVPlayer alloc] initWithURL:url];

    
    
    
    AVPlayerLayer* playerLaye = [AVPlayerLayer playerLayerWithPlayer:_player];
    playerLaye.frame = self.view.bounds;
    [image.layer addSublayer:playerLaye];
    [image setNeedsLayout];
    [_player play];
    [_player setRate:4];//播放速度

    //播放完成通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    

    //监听旋转
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];


    
    

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


//屏幕旋转
//- (void)statusBarOrientationChange:(NSNotification *)notification
//{
//    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
//    if(orientation == UIInterfaceOrientationPortrait||orientation == UIInterfaceOrientationPortraitUpsideDown){
//        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
//    }
//    
//}

//屏幕方向
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}


#pragma action
//点击事件
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (_isFisttPlay == NO) {
       [self back];
    }
}


-(void)playEnd{
    NSLog(@"播放完成");
   [self back];
}

#pragma back
-(void)back{
    playVideo = nil;
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    [_player replaceCurrentItemWithPlayerItem:nil];
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
