//
//  ModifyNameViewController.m
//  BluetoothTest1
//
//  Created by 9377 on 15/8/21.
//  Copyright (c) 2015年 9377. All rights reserved.
//

#import "ModifyNameViewController.h"
#import "BluetoothCentral.h"
@interface ModifyNameViewController ()

@end

@implementation ModifyNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
   
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)modifyName:(id)sender {
    
    BluetoothCommand *command = [[BluetoothCommand alloc] init];
    command.serviceUUIDString = kServiceUUIDFFF0;
    command.characteristicUUIDString = kCharacteristicUUIDFFF6;
    command.executeType = 1;
    
    unsigned char data [3]= {0};
    data[0] = 0xA8;
    *(data+1) = 0x00;
    *(data+2) = 0x00;
    NSData *nsdata = [NSData dataWithBytes:data length: sizeof(char)*3];
    
    command.commandData = nsdata ;
    NSLog(@"bing = %@",nsdata);
    [[BluetoothCentral shareInstance] execute:command];
    
    
}
@end
