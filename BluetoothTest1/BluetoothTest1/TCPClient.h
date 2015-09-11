//
//  TCPClient.h
//  BluetoothTest1
//
//  Created by 9377 on 15/8/26.
//  Copyright (c) 2015年 9377. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket.h>
#import "TCPCommand.h"

typedef enum{
    SocketOfflineByServer ,      //服务器掉线
    SocketOfflineByUser,        //用户断开
    SocketOfflineByWifiCut     //wifi 断开
}SocketState;

#define TCPClientErrorDomain @"com.TCPClient.error"

typedef enum {
    TCPConnectedFailed = -1000,//连接错误
    TCPRequestTimeout,  //请求超时
}TCPClientErrorFailed;

@interface TCPClient : NSObject <GCDAsyncSocketDelegate>
{
    long _tag;
    
}
@property (nonatomic, strong) NSString       *HOST;
@property (nonatomic, assign) NSInteger      PORT;
@property (nonatomic, assign) NSInteger      CONNECT_TIME_OUT;
@property (nonatomic, assign) NSInteger      HEARTTIME;     // 心跳时间
@property (nonatomic, assign) SocketState socketState;

@property (nonatomic, strong) GCDAsyncSocket *socket;       // socket

@property (nonatomic, strong) TCPCommand     *heartCommand; //心跳命令
@property (nonatomic, retain) NSTimer        *heartTimer;   // 心跳计时器
@property (nonatomic, strong) NSMutableData  *responseData;

@property (nonatomic, copy) void (^didFinishBlock) (GCDAsyncSocket *socket,NSDictionary *result,NSError *err);

@property (nonatomic, strong) NSMutableArray *tcpCommands;  //包命令数组 临时存储作用

+(id)shareInstance;

- (void)connectToHost:(NSString *)host onPort:(uint16_t)port;

- (void)writeCommand:(TCPCommand *)tcpCommand;              //发送命令，带心跳包验证

- (void)cutOffSocket;                                       //断开连接
@end
