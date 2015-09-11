//
//  BluetoothCommand.h
//  BluetoothTest1
//
//  Created by 9377 on 15/8/20.
//  Copyright (c) 2015年 9377. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#define kServiceUUIDFFF0 @"FFF0"
#define kCharacteristicUUIDFFF1 @"FFF1"
#define kCharacteristicUUIDFFF2 @"FFF2"
#define kCharacteristicUUIDFFF3 @"FFF3"
#define kCharacteristicUUIDFFF4 @"FFF4"
#define kCharacteristicUUIDFFF5 @"FFF5"
#define kCharacteristicUUIDFFF6 @"FFF6"
#define kCharacteristicUUIDFFFA @"FFFA"
#define kCharacteristicUUIDFFFB @"FFFB"

typedef enum {
    ExecuteRead = 0,
    ExecuteWrite = 1,
    ExecuteNotify = 2,
    ExecuteUnNotify = 3
}ExecuteType;

@interface BluetoothCommand : NSObject<CBPeripheralDelegate>
@property (nonatomic, strong) NSString *serviceUUIDString;
@property (nonatomic, strong) NSString *characteristicUUIDString;
@property (nonatomic, strong) NSData *commandData;
@property (nonatomic, assign) ExecuteType executeType;
@property (nonatomic, assign) BOOL isWaiting;

@end
