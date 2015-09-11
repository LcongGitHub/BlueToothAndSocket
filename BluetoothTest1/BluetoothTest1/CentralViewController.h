//
//  CentralViewController.h
//  BluetoothTest1
//
//  Created by 9377 on 15/8/18.
//  Copyright (c) 2015年 9377. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface CentralViewController : BaseViewController
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UITextView *logView;
@end
