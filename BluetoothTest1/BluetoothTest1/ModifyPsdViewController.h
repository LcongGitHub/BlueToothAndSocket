//
//  ModifyPsdViewController.h
//  BluetoothTest1
//
//  Created by 9377 on 15/8/19.
//  Copyright (c) 2015年 9377. All rights reserved.
//

#import "BaseViewController.h"

@interface ModifyPsdViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UITextField *textField;
- (IBAction)bingEvent:(id)sender;
- (IBAction)modifyEvent:(id)sender;

@end
