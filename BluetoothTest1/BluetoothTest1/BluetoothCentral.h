//
//  BluetoothCentral.h
//  BluetoothTest1
//
//  Created by 9377 on 15/8/18.
//  Copyright (c) 2015年 9377. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BluetoothCommand.h"
#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface BluetoothCentral : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>
{
    BOOL _isSearchPeripheral;
    MBProgressHUD *HUD;
    NSInteger _curTime;
    NSTimer *_curTimer;
}

@property (strong,nonatomic) CBCentralManager *centralManager;//中心设备管理器
@property (strong,nonatomic) NSMutableArray *peripherals;//扫描所有存在外围设备

@property (nonatomic, copy) void (^searchPeripheralBlock) (NSMutableArray *periphrals);//查询外设回调
@property (nonatomic, copy) void (^didConnectPeripheralBlock) (BOOL isConnected);//连接外设回调
@property (nonatomic, assign) BOOL isFinishedRequest;
@property (nonatomic, assign) NSInteger maxOutTime;
//@property (nonatomic, copy) void (^didUpdateValueBlock) (NSString *value,CBCharacteristic *characteristic); //更新值回调

@property (nonatomic,strong) CBPeripheral *peripheral; //当前连接的外设
@property (nonatomic, strong) NSMutableArray *services;
@property (nonatomic, strong) NSMutableArray *characteristics;
+(BluetoothCentral *)shareInstance;
-(void)startCentral;
-(void) searchPeripheral;
- (void) stopSearchPeripheral;
- (void) connectPeripheral:(CBPeripheral *)peripheral;
- (void) execute:(BluetoothCommand *)bluetoothCommand;
@end
