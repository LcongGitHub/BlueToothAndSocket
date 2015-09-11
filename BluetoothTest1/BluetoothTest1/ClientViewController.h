//
//  ClientViewController.h
//  BluetoothTest1
//
//  Created by 9377 on 15/8/24.
//  Copyright (c) 2015年 9377. All rights reserved.
//

#import "BaseViewController.h"
#import <CocoaAsyncSocket.h>

@interface ClientViewController : BaseViewController<AsyncSocketDelegate>
@property (strong, nonatomic) IBOutlet UITextField *hostTF;
@property (strong, nonatomic) IBOutlet UITextField *portTF;
@property (strong, nonatomic) IBOutlet UITextField *username;

@property (strong, nonatomic) IBOutlet UITextField *passwrod;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
