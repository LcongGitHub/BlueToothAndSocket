//
//  BluetoothCentral.m
//  BluetoothTest1
//
//  Created by 9377 on 15/8/18.
//  Copyright (c) 2015年 9377. All rights reserved.
//

#import "BluetoothCentral.h"



@implementation BluetoothCentral
+(BluetoothCentral *)shareInstance{
    static BluetoothCentral *s = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s = [[BluetoothCentral alloc] init];
        s.isFinishedRequest = YES;
        s.maxOutTime = 10;
           });
    return s;
}

//扫描外设
-(void) searchPeripheral{
    [self cleanup];
    _isSearchPeripheral = YES;
    [self.centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
}

//停止扫描外设
- (void) stopSearchPeripheral{
    [self.centralManager stopScan];
}

//连接外设
- (void)connectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"连接外设");
    peripheral.delegate=self;
    [self.centralManager connectPeripheral:peripheral options:nil];
}

//发现服务
- (void)discoverService:(NSString *)serviceUUID{
    [self.peripheral discoverServices:@[[CBUUID UUIDWithString:serviceUUID]]];
}

//执行命令
- (void)execute:(BluetoothCommand *)bluetoothCommand{
    if(self.isFinishedRequest && bluetoothCommand.isWaiting ){
       _curTimer= [NSTimer timerWithTimeInterval:1 target:self selector:@selector(outtime) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_curTimer forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] run];
        [self showHUD];
    }
    
    switch (bluetoothCommand.executeType) {
        case 0:{
            [self readData:bluetoothCommand];
        }
            break;
        case 1:{
            [self writeData:bluetoothCommand];
        }
            break;
        case 2:{
            [self notifyData:bluetoothCommand isNotify:YES];
        }
            break;
        case 3:{
            [self notifyData:bluetoothCommand isNotify:NO];
        }
            break;
        default:
            break;
    }
}

- (void)outtime{
    _curTime ++;
    if(_curTime >= _maxOutTime){
        [self closeCharge];
    }
}

- (void)closeCharge{
    [self stopTimer];
    Byte dataArr[1];
    dataArr[0]=0xa0;
    NSData * myData = [NSData dataWithBytes:dataArr length:1];
    BluetoothCommand *command = [[BluetoothCommand alloc] init];
    command.serviceUUIDString = kServiceUUIDFFF0;
    command.characteristicUUIDString = kCharacteristicUUIDFFF1;
    command.executeType = 1;
    command.commandData = myData;
    [[BluetoothCentral shareInstance] execute:command];
}

- (void)stopTimer{
    _isFinishedRequest = YES;
    
    if([_curTimer isValid])
        [_curTimer invalidate];
    [self hideHUD];

}

- (void)writeData:(BluetoothCommand *)bluetoothCommand{
    NSLog(@"all cha = %@ %@",self.peripheral,self.characteristics);
    if(!bluetoothCommand.commandData)
        return;
    for(CBCharacteristic *characteristic in self.characteristics){
        if([characteristic.UUID.UUIDString isEqualToString:bluetoothCommand.characteristicUUIDString] && [characteristic.service.UUID.UUIDString isEqualToString:bluetoothCommand.serviceUUIDString]){
            [self.peripheral writeValue:bluetoothCommand.commandData forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
            break;
        }
    }
}

- (void)readData:(BluetoothCommand *)bluetoothCommand{
    NSLog(@"all cha = %@ %@",self.peripheral,self.characteristics);

    for(CBCharacteristic *characteristic in self.characteristics){
        if([characteristic.UUID.UUIDString isEqualToString:bluetoothCommand.characteristicUUIDString] && [characteristic.service.UUID.UUIDString isEqualToString:bluetoothCommand.serviceUUIDString]){
            [self.peripheral readValueForCharacteristic:characteristic];
            break;
        }
    }
}

- (void)notifyData:(BluetoothCommand *)bluetoothCommand isNotify:(BOOL)isNotify{
    NSLog(@"all cha = %@ %@",self.peripheral,self.characteristics);
    
    for(CBCharacteristic *characteristic in self.characteristics){
        if([characteristic.UUID.UUIDString isEqualToString:bluetoothCommand.characteristicUUIDString] && [characteristic.service.UUID.UUIDString isEqualToString:bluetoothCommand.serviceUUIDString]){
            [self.peripheral setNotifyValue:isNotify forCharacteristic:characteristic];
            break;
        }
    }
}

#pragma mark - CBCentralManager代理方法
//中央设备状态更新后
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBPeripheralManagerStatePoweredOn:
        {
            NSLog(@"BLE已打开.");
            //扫描外围设备
            if(_isSearchPeripheral)
                [self searchPeripheral];
            else if(self.peripheral){
                [self.centralManager connectPeripheral:self.peripheral options:nil];
            }
        }
            break;
        case CBPeripheralManagerStatePoweredOff:
        {
            
        }
            break;
        default:{
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"此设备不支持BLE或未打开蓝牙功能，无法作为外围设备." delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//            [alert show];
//            NSLog(@"此设备不支持BLE或未打开蓝牙功能，无法作为外围设备.");
        }
            break;
    }
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"发现外围设备...");
    //连接外围设备
    
    if (RSSI.integerValue > -15 || RSSI.integerValue < -80) {
        if (peripheral) {
            //添加保存外围设备，注意如果这里不保存外围设备（或者说peripheral没有一个强引用，无法到达连接成功（或失败）的代理方法，因为在此方法调用完就会被销毁
            if([self.peripherals containsObject:peripheral]){
                [self.peripherals removeObject:peripheral];
            }
        }
        return;
    }
   
    if (peripheral) {
        //添加保存外围设备，注意如果这里不保存外围设备（或者说peripheral没有一个强引用，无法到达连接成功（或失败）的代理方法，因为在此方法调用完就会被销毁
        if(![self.peripherals containsObject:peripheral]){
            [self.peripherals addObject:peripheral];
        }
    }
    if(_searchPeripheralBlock){
        _searchPeripheralBlock(self.peripherals);
    }
}

//连接到外围设备
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"连接外围设备成功!");
    [self stopSearchPeripheral];
    _isSearchPeripheral = NO;
    //设置外围设备的代理为当前视图控制器
    [self.characteristics removeAllObjects];
    self.peripheral = peripheral;
    [self.peripheral discoverServices:nil];
}

//连接外围设备失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"连接外围设备失败!");
    if(_didConnectPeripheralBlock){
        _didConnectPeripheralBlock(NO);
    }
}

//已断开从机的链接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    //尝试重连
    if(self.peripheral && !self.peripheral.isConnected){
        [self.centralManager connectPeripheral:self.peripheral options:nil];
    }
}


#pragma mark - CBPeripheral 代理方法
//外围设备寻找到服务后
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    NSLog(@"已发现可用服务...");
    if(error){
        [self cleanup];
        NSLog(@"外围设备寻找服务过程中发生错误，错误信息：%@",error.localizedDescription);
        return;
    }
    [self.services removeAllObjects];
    [self.services addObjectsFromArray:peripheral.services];
    for(CBService *service in peripheral.services){
        [self.peripheral discoverCharacteristics:nil forService:service];
    }
}

//外围设备寻找到特征后
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    NSLog(@"已发现可用特征...");
    if (error) {
        [self cleanup];
        NSLog(@"外围设备寻找特征过程中发生错误，错误信息：%@",error.localizedDescription);
        return;
    }
    NSLog(@"all services = %@",self.services);
    for(CBService *s in self.services){
        if([s.UUID isEqual:service.UUID]){
            [self.services removeObject:s];
            [self.characteristics addObjectsFromArray:service.characteristics];
            break;
        }
    }
    
    for(CBCharacteristic *c in service.characteristics){
        if(c.properties & CBCharacteristicPropertyNotify){
            [self.peripheral setNotifyValue:YES forCharacteristic:c];
        }
        
    }
    
    if(self.services.count == 0){
        if(_didConnectPeripheralBlock){
            _didConnectPeripheralBlock(YES);
        }
    }
}

//特征值被更新后
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"更新通知状态时发生错误，错误信息：%@",error.localizedDescription);
    }
    NSLog(@"CENTRAL1: peripheral:%@ didWriteValueForCharacteristic:%@ error:%@",
          peripheral, characteristic, [error description]);
    
    //给特征值设置新的值
    if (characteristic.isNotifying) {
        if (characteristic.properties & CBCharacteristicPropertyNotify) {
            
            if(characteristic.value){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"BluetoothNotify" object:nil userInfo:@{@"characteristic":characteristic}];
                
            }
            
        }else if (characteristic.properties & CBCharacteristicPropertyRead) {
            [peripheral readValueForCharacteristic:characteristic];
        }else{
            NSLog(@"fdfd");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
        
    }else{
        NSLog(@"停止已停止.");
        //取消连接
    }
}

//更新特征值后（调用readValueForCharacteristic:方法或者外围设备在订阅后更新特征值都会调用此代理方法）
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"更新特征值时发生错误，错误信息：%@",error.localizedDescription);
        return;
    }
    NSLog(@"CENTRAL2: peripheral:%@ didWriteValueForCharacteristic:%@ error:%@",
          peripheral, characteristic, [error description]);
   
    if(characteristic.value){
        if([characteristic.UUID.UUIDString isEqualToString:kCharacteristicUUIDFFF4]){
            NSString *aString = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];

            if([aString isEqualToString:@"01"]){
                [self stopTimer];
            }else if([aString isEqualToString:@"02"])
                [self closeCharge];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BluetoothNotify" object:nil userInfo:@{@"characteristic":characteristic}];
    }
}

//写数据代理
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
{
    if (error) {
        NSLog(@"更新特征值时发生错误，错误信息：%@",error.localizedDescription);
        return;
    }
    NSLog(@"CENTRAL3: peripheral:%@ didWriteValueForCharacteristic:%@ error:%@",
          peripheral, characteristic, [error description]);
}

- (void)cleanup
{
    // Don't do anything if we're not connected
    if (!self.peripheral.isConnected) {
        return;
    }
    
    // See if we are subscribed to a characteristic on the peripheral
    if (self.peripheral.services != nil) {
        for (CBService *service in self.peripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if (characteristic.isNotifying) {
                        // It is notifying, so unsubscribe
                        [self.peripheral setNotifyValue:NO forCharacteristic:characteristic];
                    }
                }
            }
        }
    }
    [self.characteristics removeAllObjects];
    // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
}


#pragma mark - 属性
-(NSMutableArray *)peripherals{
    if(!_peripherals){
        _peripherals = [[NSMutableArray alloc] init];
    }
    return _peripherals;
}
-(CBCentralManager *)centralManager{
    if(!_centralManager){
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return _centralManager;
}

-(NSMutableArray *)services{
    if(!_services){
        _services = [[NSMutableArray alloc] init];
    }
    return _services;
}

-(NSMutableArray *)characteristics{
    if(!_characteristics){
        _characteristics = [[NSMutableArray alloc] init];
    }
    return _characteristics;
}

#pragma mark - MBHUD 
-(void)showHUD
{
    HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    //    HUD.labelText = @"正在加载";
}
-(void)hideHUD
{
    [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
}


@end
