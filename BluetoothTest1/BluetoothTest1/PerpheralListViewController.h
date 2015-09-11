//
//  PerpheralListViewController.h
//  BluetoothTest1
//
//  Created by 9377 on 15/8/18.
//  Copyright (c) 2015年 9377. All rights reserved.
//

#import "BaseViewController.h"
#import "BluetoothCentral.h"

@interface PerpheralListViewController : BaseViewController

@property (nonatomic, copy) void (^didSelectedPeripheral) (CBPeripheral *peripheral);
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
