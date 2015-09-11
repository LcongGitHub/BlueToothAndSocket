//
//  AppDelegate.m
//  BluetoothTest1
//
//  Created by 9377 on 15/8/18.
//  Copyright (c) 2015年 9377. All rights reserved.
//

#import "AppDelegate.h"
#import "KWOfficeApi.h"
#import <CocoaLumberjack.h>
#import "NSData+AES.h"


static const NSInteger ddLogLevel = DDLogLevelAll;
@interface AppDelegate ()<KWOfficeApiDelegate>
{
    NSDictionary *_OfficeInfo;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //DDLog config
    setenv("XcodeColors", "YES", 1);
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];

    [KWOfficeApi registerApp:@"78530E3D71A93B61CDD292808343C19C"];
    /// @note 打开调试模式
    [KWOfficeApi setDebugMode:YES];
    /// @note 设置通信端口号，默认9616
    [KWOfficeApi setPort:9616];

    [self copyFile2Documents:@"欢迎使用WPS.doc"];
    [self copyFile2Documents:@"贷款计算器.xls"];
    [self copyFile2Documents:@"休闲时光.ppt"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(runWpsAppEvent:) name:@"RunWpsAppNotifi" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(runWpsExcelAppEvent:) name:@"RunWpsExcelAppNotifi" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(runWpsPPTAppEvent:) name:@"RunWpsPPTAppNotifi" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(runWpsPDFAppEvent:) name:@"RunWpsPDFAppNotifi" object:nil];
   

    return YES;
}

-(void)copyFile2Documents:(NSString*)fileName
{
    NSFileManager *fileManager =[NSFileManager defaultManager];
    NSString * filePath = [self filePath:fileName];
    NSLog(@"filePaht = %@",filePath);
    if([fileManager fileExistsAtPath:filePath] == NO){
        NSString *strDocPath = [[NSString alloc] initWithString:[self getDocPath]];
        [fileManager createDirectoryAtPath:strDocPath withIntermediateDirectories:NO attributes:nil error:nil];
        
        NSString *resourcePath =[[NSBundle mainBundle] pathForResource:fileName ofType:nil];
        NSData *data = [NSData dataWithContentsOfFile:resourcePath];
        NSData *encryData = [data AESEncryptWithKey:@"EA12824C48B60799"];
        [fileManager createFileAtPath:filePath contents:encryData attributes:nil];
    }
}

- (NSString *)filePath:(NSString *)fileName{
    NSString * documentsDirectory = [self getDocPath];
    NSString * filePath =[documentsDirectory stringByAppendingPathComponent:fileName];
    return filePath;
}

- (NSData *)getFileName:(NSString *)fileName{
    NSString *filePath = [self filePath:fileName];
    NSFileManager *fileManager =[NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:filePath] == YES){
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        return data;
    }else
        return nil;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[KWOfficeApi sharedInstance] setApplicationDidEnterBackground:application];//必须使用

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - KWOfficeApi delegate
//wps回传文件数据
-(void)KWOfficeApiDidReceiveData:(NSDictionary *)dict
{
    //解析file数据
    NSData *fileData = [dict objectForKey:@"Body"];
    
    //将file data 写入本地
    NSString *strDocPath = [[NSString alloc] initWithString:[self getDocPath]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    [fileManager createDirectoryAtPath:strDocPath withIntermediateDirectories:NO attributes:nil error:&error];
    
    NSData *encryData = [fileData AESEncryptWithKey:[_OfficeInfo objectForKey:@"key"]];
    [fileManager createFileAtPath:[strDocPath stringByAppendingPathComponent:[_OfficeInfo objectForKey:@"fileName"]] contents:encryData attributes:nil];
    
}

//wps编辑完成返回 结束与WPS链接
- (void)KWOfficeApiDidFinished
{
    NSLog(@"=====> wps编辑完成返回 结束与WPS链接");
}

//wps退出后台
- (void)KWOfficeApiDidAbort
{
    NSLog(@"wps编辑结束，并退出后台");
}
//断开链接
- (void)KWOfficeApiDidCloseWithError:(NSError*)error
{
    NSLog(@"=====> 错误 与 wps 断开链接 %@",error);
}


#pragma mark - 写本地文件
-(NSString *)getDocumentPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

//doc路径
-(NSString *)getDocPath{
    return[[self getDocumentPath] stringByAppendingPathComponent:@"doc"];
}

//nsdata转文件
-(BOOL)writeFile:(NSString *)path writeData:(NSData *)data{
    BOOL isSuccess=[data writeToFile:path atomically:NO];
    return isSuccess;
}

-(void)KWAOfficepiDidCloseWithError:(NSError *)error
{
    NSLog(@"DemoOa 的 KWOfficeApi 断开");
}

#pragma mark - 进入wps
-(void)runWpsAppEvent:(NSNotification *)notification
{
    
    NSDictionary *userInfo = notification.userInfo;
    
    _OfficeInfo = userInfo;

    NSString *filePath = [self filePath:[userInfo objectForKey:@"fileName"]];
    
    NSData *encryData = [self getFileName:[userInfo objectForKey:@"fileName"]];
    
    NSData *decryData = [encryData AESDecryptWithKey:[userInfo objectForKey:@"key"]];
    
    NSLog(@"FILAPATH = %@",filePath);
    if (decryData == nil)
        return;
    
    NSError *error = nil;
    BOOL isOk = [[KWOfficeApi sharedInstance] sendFileData:decryData
                                              withFileName:filePath.lastPathComponent
                                                  callback:nil
                                                  delegate:self
                                                    policy:@{
                                                             @"wps.document.editMode": @"0",
                                                             @"wps.document.openInEditMode":@"1",
                                                             @"wps.document.revision.username": @"Glider",
                                                             @"public.shell.backup": @"0",
                                                             @"wps.shell.editmode.toolbar.mark":@"1",
                                                             @"wps.shell.editmode.toolbar.markEnable":@"0",
                                                             @"wps.shell.editmode.toolbar.revision":@"0",
                                                             @"wps.shell.editmode.toolbar.revisionEnable":@"1",
                                                             @"wps.shell.readmode.toolbar.revision":@"0"
                                                             }
                                                     error:&error];
    if (isOk) {
        NSLog(@"进入wps app");
    } else {
        NSLog(@"进入wps app 失败 %@", error);
    }
}


- (void)runWpsExcelAppEvent:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    _OfficeInfo = userInfo;
    
    NSString *filePath = [self filePath:[userInfo objectForKey:@"fileName"]];
    
    NSData *encryData = [self getFileName:[userInfo objectForKey:@"fileName"]];
    
    NSData *decryData = [encryData AESDecryptWithKey:[userInfo objectForKey:@"key"]];
    
    if (decryData == nil)
        return;

    NSError *error = nil;
    BOOL isOk = [[KWOfficeApi sharedInstance] sendFileData:decryData
                                              withFileName:filePath.lastPathComponent
                                                  callback:nil
                                                  delegate:self
                                                    policy:@{@"et.document.editMode":@"1",@"et.document.saveAs":@"1" }
                                                     error:&error];
    if (isOk) {
        NSLog(@"进入wps app");
    } else {
        NSLog(@"进入wps app 失败 %@", error);
    }
}

- (void)runWpsPPTAppEvent:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    _OfficeInfo = userInfo;
    
    NSString *filePath = [self filePath:[userInfo objectForKey:@"fileName"]];
    
    NSData *encryData = [self getFileName:[userInfo objectForKey:@"fileName"]];
    
    NSData *decryData = [encryData AESDecryptWithKey:[userInfo objectForKey:@"key"]];
    
    if (decryData == nil)
        return;
    
    NSError *error = nil;
    BOOL isOk = [[KWOfficeApi sharedInstance] sendFileData:decryData
                                              withFileName:filePath.lastPathComponent
                                                  callback:nil
                                                  delegate:self
                                                    policy:@{@"ppt.document.editMode":@"1", @"ppt.document.saveAs":@"1"}
                                                     error:&error];
    if (isOk) {
        NSLog(@"进入wps app");
    } else {
        NSLog(@"进入wps app 失败 %@", error);
    }
}


- (void)runWpsPDFAppEvent:(NSNotification*)notification
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"PDF操作指南" ofType:@"pdf"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data == nil)
        return;
    
    NSError *error = nil;
    BOOL isOk = [[KWOfficeApi sharedInstance] sendFileData:data
                                              withFileName:path.lastPathComponent
                                                  callback:nil
                                                  delegate:self
                                                    policy:nil
                                                     error:&error];
    if (isOk) {
        NSLog(@"进入wps app");
    } else {
        NSLog(@"进入wps app 失败 %@", error);
    }
}


@end
