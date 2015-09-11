//
//  BaseViewController.h
//  BluetoothTest1
//
//  Created by 9377 on 15/8/18.
//  Copyright (c) 2015年 9377. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
@interface BaseViewController : UIViewController
{
    MBProgressHUD *HUD;

}
-(void)showTextHUD:(NSString *)text;

-(void)showHUD;

-(void)hideHUD;

- (void)showBack;
- (void)showRight:(NSString *)str target:(id)t sel:(SEL)s ;

@end
