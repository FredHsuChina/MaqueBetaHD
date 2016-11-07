//
//  ViewController.m
//  maqueBetaHD
//
//  Created by 许文锋 on 16/11/7.
//  Copyright © 2016年 fred. All rights reserved.
//

#import "ViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "MainViewController.h"

#define SCRIEEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCRIEEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

#define ALERT_SHOW(title,msg) UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];\
[alert show];

#define HexRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
// 系统版本
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
@interface ViewController ()<UIWebViewDelegate>

@end

@implementation ViewController{
    UIWebView *headView;
    UIWebView *mainView;
    JSContext *context;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"麻游助手";
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.barTintColor=HexRGB(0x4585d7);
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    if(IOS_VERSION < 7.0){
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                        NSFontAttributeName : [UIFont boldSystemFontOfSize:19.0f]};
    }else{
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont boldSystemFontOfSize:19.0f], NSFontAttributeName, nil];
    }
    [self preferredStatusBarStyle];
    //    self.navigationController.navigationBar.barTintColor = [UIColor blueColor];
    //    headView  = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCRIEEN_WIDTH, 64)];
    //    headView.scrollView.scrollEnabled = NO;
    UIBarButtonItem *contactMeBtn = [[UIBarButtonItem alloc] initWithTitle:@"联系我们" style:UIBarButtonItemStylePlain target:self action:@selector(contactMe:)];
    self.navigationItem.rightBarButtonItem = contactMeBtn;
    mainView =  [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCRIEEN_WIDTH, SCRIEEN_HEIGHT)];
    mainView.scrollView.scrollEnabled = YES;
    [mainView setBackgroundColor:[UIColor whiteColor]];
    mainView.delegate   = self;
    mainView.dataDetectorTypes  = UIDataDetectorTypeAll;
    [self.view addSubview:headView];
    [self.view addSubview:mainView];
    [self initDatas];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
     -(UIStatusBarStyle)preferredStatusBarStyle{
         return UIStatusBarStyleLightContent;
     }
     -(BOOL)prefersStatusBarHidden{
         return NO;
     }
     -(void)initDatas{
         NSURL *pathURL = [[NSBundle mainBundle] URLForResource:@"main.html" withExtension:nil];
         [mainView loadRequest:[NSURLRequest requestWithURL:pathURL]];
     }
     -(void)webViewDidFinishLoad:(UIWebView *)webView{
         
         if(context == nil){
             
             context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
             
             
             context.exceptionHandler = ^(JSContext* context,JSValue* exceptionValue){
                 dispatch_async(dispatch_get_main_queue(), ^{
                     ALERT_SHOW(@"", @"网络异常");
                 });
             };
             __block ViewController* blockSelf = self;
             context[@"imageFunction"] = ^(id name,id url){
                 dispatch_async(dispatch_get_main_queue(), ^{
                     NSLog(@"执行openWin");
                     MainViewController *mainVC = [[MainViewController alloc] init];
                     mainVC.urlName = @"function_d.html";
                     mainVC.title = @"功能列表";
                     [blockSelf.navigationController pushViewController:mainVC animated:YES];
                 });
             };
         }
         
     }
     -(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
         
         return YES;
     }
     
     -(void)contactMe:(id)sender{
         MainViewController *mainVC = [[MainViewController alloc] init];
         mainVC.urlName = @"lianxi_d.html";
         mainVC.title = @"联系我们";
         [self.navigationController pushViewController:mainVC animated:YES];
     }


@end
