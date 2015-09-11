//
//  TCPCommand.h
//  BluetoothTest1
//
//  Created by 9377 on 15/8/28.
//  Copyright (c) 2015年 9377. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCPCommand : NSObject
@property (nonatomic, strong) NSArray *xmlArray; //参数数组
@property (nonatomic, assign) NSUInteger bagID;  //命令包ID
@property (nonatomic, assign) NSInteger WRITE_TIME_OUT; //写超时限制 默认不超时
@property (nonatomic, assign) NSInteger READ_TIME_OUT; //写超时限制 默认不超时
@property (nonatomic, assign) NSInteger MAX_BUFFER; //接收字符
@property (nonatomic, assign) long tag;
@property (nonatomic, strong) NSData *paramsData; //设置参数数组后 直接获取就可得到
@property (nonatomic, assign) BOOL isOpenHeartCheck; //当前命令是否开启心跳检测
@end
