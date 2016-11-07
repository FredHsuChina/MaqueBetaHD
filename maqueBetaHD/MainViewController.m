//
//  MainViewController.m
//  maqueBetaHD
//
//  Created by 许文锋 on 16/11/7.
//  Copyright © 2016年 fred. All rights reserved.
//

#import "MainViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

#define SCRIEEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCRIEEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

#define ALERT_SHOW(title,msg) UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];\
[alert show];
@interface MainViewController ()<UIWebViewDelegate>

@end

@implementation MainViewController{
    UIWebView *mainWebView;
    JSContext *context;
    BOOL isOpenGame;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initViews];
    [self initDatas];
}

-(void)initViews{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    mainWebView  = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCRIEEN_WIDTH, SCRIEEN_HEIGHT)];
    [mainWebView setBackgroundColor:[UIColor whiteColor]];
    mainWebView.delegate = self;
    mainWebView.dataDetectorTypes = UIDataDetectorTypeAll;
    [self.view addSubview:mainWebView];
    
    if (!_noNeedPermit) {
        UIBarButtonItem *contactMeBtn = [[UIBarButtonItem alloc] initWithTitle:@"授权" style:UIBarButtonItemStylePlain target:self action:@selector(getPermition:)];
        self.navigationItem.rightBarButtonItem = contactMeBtn;
    }
}

-(void)initDatas{
    NSURL *pathURL = [[NSBundle mainBundle] URLForResource:_urlName withExtension:nil];
    [mainWebView loadRequest:[NSURLRequest requestWithURL:pathURL]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    if(context == nil){
        
        context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        
        
        context.exceptionHandler = ^(JSContext* context,JSValue* exceptionValue){
            dispatch_async(dispatch_get_main_queue(), ^{
                ALERT_SHOW(@"", @"网络异常");
            });
        };
        __block MainViewController* blockSelf = self;
        context[@"openPage"] = ^(id pageName,id title){
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"执行openPage");
                MainViewController *mainVC = [[MainViewController alloc] init];
                mainVC.urlName =[NSString stringWithFormat:@"%@.html",pageName];
                mainVC.title = title;
                [blockSelf.navigationController pushViewController:mainVC animated:YES];
            });
        };
        context[@"jihuo"] = ^(){
            //            NSString *code = value;
            NSString *code =[webView stringByEvaluatingJavaScriptFromString:@"$('#ma').val()"];
            if (code==nil||[@"" isEqualToString:code]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [blockSelf alertShow:@"激活码不能为空" isNeedOther:NO isNeedClose:NO];
                });
            }
            if([code isEqualToString:@"qwe987"]||[code isEqualToString:@"asd321"]||[code isEqualToString:@"zxc456"]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [blockSelf alertShow:@"是否确定激活?" isNeedOther:YES isNeedClose:NO];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [blockSelf alertShow:@"激活码不存在" isNeedOther:NO isNeedClose:NO];
                });
            }
            
        };
        context[@"qidong"] = ^(){
            //            NSString *code = value;
            isOpenGame = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [blockSelf alertShow:@"是否启动游戏?" isNeedOther:YES isNeedClose:NO];
            });
            
        };
        
    }
}
-(void)alertShow:(NSString *)message isNeedOther:(BOOL)isNeedOther isNeedClose:(BOOL)isNeedClose{
    NSString *title = @"麻游助手";
    NSString *cancelBtnTitle = @"取消";
    if (!isNeedOther) {
        cancelBtnTitle = @"确定";
    }
    
    NSString *otherBtnTitle = @"确定";
    __block MainViewController* blockSelf = self;
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelBtnTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (isNeedClose) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    if (isNeedOther) {
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherBtnTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //确定按钮
            if (isOpenGame) {
                //启动游戏
                //                BOOL isJiHuo =[[NSUserDefaults standardUserDefaults] objectForKey:@"jihuo"];
                //                if (isJiHuo==YES) {
                //                    NSDictionary *option = @{@"ab":@"1"};
                //                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"firegame-GoldMinerFree://"] options:option completionHandler:^(BOOL success) {
                //
                //                    }];
                //                }else{
                [blockSelf alertShow:@"启动成功" isNeedOther:NO isNeedClose:NO];
                //                }
            }else{
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"jihuo"];
                [blockSelf alertShow:@"激活成功" isNeedOther:NO isNeedClose:YES];
            }
        }];
        [alertVC addAction:otherAction];
    }else{
        [alertVC addAction:cancelAction];
    }
    [self presentViewController:alertVC animated:YES completion:^(){
        
    }];
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    return YES;
}
-(void)getPermition:(id)sender{
    MainViewController *mainVC = [[MainViewController alloc] init];
    mainVC.urlName = @"jihuo_d.html";
    mainVC.title = @"授权激活";
    mainVC.noNeedPermit = YES;
    [self.navigationController pushViewController:mainVC animated:YES];
}
@end
