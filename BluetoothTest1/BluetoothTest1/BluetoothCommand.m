//
//  BluetoothCommand.m
//  BluetoothTest1
//
//  Created by 9377 on 15/8/20.
//  Copyright (c) 2015年 9377. All rights reserved.
//

#import "BluetoothCommand.h"
@implementation BluetoothCommand


- (NSString *)description
{
    return [NSString stringWithFormat:@"command --- >%@-%@", self.serviceUUIDString,self.characteristicUUIDString];
}
@end
