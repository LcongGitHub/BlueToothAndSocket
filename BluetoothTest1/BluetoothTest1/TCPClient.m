//
//  TCPClient.m
//  BluetoothTest1
//
//  Created by 9377 on 15/8/26.
//  Copyright (c) 2015年 9377. All rights reserved.
//

#import "TCPClient.h"
#import <XMLDictionary.h>

#define HeartTag 0

@implementation TCPClient

+(id)shareInstance
{
    static id s;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s = [[[self class] alloc] init];
    });
    return s;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _tag = 1;
        
        self.CONNECT_TIME_OUT = -1;//默认值 不超时
        self.HEARTTIME        = 1;//采用定时器请求心跳默认时间 1秒
    }
    return self;
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSLog(@"didAcceptNewSocket");
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    //这是异步返回的连接成功，
    NSLog(@"didConnectToHost");
    //通过定时器不断发送心跳包，来检测长连接
    //    if (!self.heartTimer || ![self.heartTimer isValid])
    //    {
    //        self.heartTimer = [NSTimer scheduledTimerWithTimeInterval:self.HEARTTIME target:self selector:@selector(checkLongConnectByServe) userInfo:nil repeats:YES];
    //        [self.heartTimer fire];
    //    }
    [self checkLongConnectByServe];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"收到读信息 回调 tag = %ld",tag);
    /**
     *  获取当前返回对应的命令包
     */
    TCPCommand *tcpCommand = [self getCurCommand:tag];
    if (!tcpCommand)
    {
        NSLog(@"不存在该命令包");
        return;
    }
    
    if ( data.length < tcpCommand.MAX_BUFFER )
    {
        [self.responseData appendData:data];

//        for(int i = 0; i < self.responseData.length; i ++)
//        {
//            NSLog(@"%@",[[NSString alloc] initWithData:[self.responseData subdataWithRange:NSMakeRange(i,1)] encoding:NSUTF8StringEncoding]);
//        }
        
        //收到结果解析...
        NSString *str = [[NSString alloc] initWithData:[self.responseData subdataWithRange:NSMakeRange(14, self.responseData.length - 14)] encoding:NSUTF8StringEncoding];
        NSDictionary *temp = [NSDictionary dictionaryWithXMLString:str];
        const char*   pos =  [[self.responseData subdataWithRange:NSMakeRange(0, 4)] bytes];
        NSInteger  bagID;//命令包ID
        memcpy(&bagID, pos, sizeof(NSInteger));
        
        NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithDictionary:temp];
        [result setObject:[NSNumber numberWithInteger:bagID] forKey:@"bagID"];

        NSLog(@"\n\n\n\n-----Response Data-----------\nResponse result = %@",result);
        
        if(bagID == 1)
        {
            //心跳包返回 分长连接检测包 和 命令检测包
            if ([[result objectForKey:@"status"] integerValue] == 100)
            {
                if (tag != HeartTag)
                {
                    //如果是命令检测心跳包
                    for (TCPCommand *command in self.tcpCommands)
                    {
                        if (command.tag == tag && command.isOpenHeartCheck)
                        {
                            [self writeCommand:command withTag:command.tag];
                            break;
                        }
                    }
                }
                else
                {
                    //如果是长连接检测包
                    NSLog(@"心跳检测 长连接正常。。。");
                }
            }
            else
            {
                NSLog(@"心跳检测 错误 error = %@",result);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (_didFinishBlock)
                    {
                        _didFinishBlock(sock,result,nil);
                    }
                });
            }
        }
        else
        {
            //不是心跳包
            if (tcpCommand.bagID != 1 && [self.tcpCommands containsObject:tcpCommand])
            {
                [self.tcpCommands removeObject:tcpCommand];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (_didFinishBlock)
                    {
                        _didFinishBlock(sock,result,nil);
                    }
                });
            }
        }
        [self clearData];
    }
    else
    {
        [self.responseData appendData:data];
        [self.socket readDataWithTimeout:tcpCommand.READ_TIME_OUT buffer:nil bufferOffset:0 maxLength:tcpCommand.MAX_BUFFER tag:tag];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{
    NSLog(@"didReadPartialDataLength");
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    TCPCommand *tcpCommand = [self getCurCommand:tag];
    if (tcpCommand)
        [self.socket readDataWithTimeout:tcpCommand.READ_TIME_OUT buffer:nil bufferOffset:0 maxLength:tcpCommand.MAX_BUFFER tag:tag];
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"读取数据请求超时" forKey:NSLocalizedDescriptionKey];
    NSError *aError = [NSError errorWithDomain:TCPClientErrorDomain code:TCPRequestTimeout userInfo:userInfo];
   
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_didFinishBlock){
            _didFinishBlock(self.socket,nil,aError);
        }
    });
   
    return 0;
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"获取数据请求超时" forKey:NSLocalizedDescriptionKey];
    NSError *aError = [NSError errorWithDomain:TCPClientErrorDomain code:TCPRequestTimeout userInfo:userInfo];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_didFinishBlock){
            _didFinishBlock(self.socket,nil,aError);
        }
    });
    return 0;
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"didDisconnect = %@",err);
    switch (err.code) {
        case 7://socket 断开
        case 57:
            [self clearData];
            if (self.socketState == SocketOfflineByServer)
            {
                // 服务器掉线，重连
                if(self.HOST && self.PORT){
                    [self connectToHost:self.HOST onPort:self.PORT];
                }
            }
            else if (self.socketState == SocketOfflineByUser)
            {
                // 如果由用户断开，不进行重连
                return;
            } else if (self.socketState == SocketOfflineByWifiCut)
            {
#warning wifi断开，不进行重连 后续加入WiFi断开判断
                return;
            }
            break;
            
        default:
            dispatch_async(dispatch_get_main_queue(), ^{
                if(_didFinishBlock){
                    _didFinishBlock(self.socket,nil,err);
                }
            });
            break;
    }
    
}
/**
 * Called when a socket disconnects with or without error.
 *
 * If you call the disconnect method, and the socket wasn't already disconnected,
 * then an invocation of this delegate method will be enqueued on the delegateQueue
 * before the disconnect method returns.
 *
 * Note: If the GCDAsyncSocket instance is deallocated while it is still connected,
 * and the delegate is not also deallocated, then this method will be invoked,
 * but the sock parameter will be nil. (It must necessarily be nil since it is no longer available.)
 * This is a generally rare, but is possible if one writes code like this:
 *
 * asyncSocket = nil; // I'm implicitly disconnecting the socket
 *
 * In this case it may preferrable to nil the delegate beforehand, like this:
 *
 * asyncSocket.delegate = nil; // Don't invoke my delegate method
 * asyncSocket = nil; // I'm implicitly disconnecting the socket
 *
 * Of course, this depends on how your state machine is configured.
 **/

#pragma mark - event
- (void)clearData{
    [self.responseData resetBytesInRange:NSMakeRange(0, [self.responseData length])];
    [self.responseData setLength:0];
}

-(void)connectToHost:(NSString *)host onPort:(uint16_t)port{
    self.HOST = host;
    self.PORT = port;
    if (self.HOST && self.PORT)
    {
        NSError *error = nil;
        if(![self.socket isConnected])
        {
            BOOL isSuccess = [self.socket connectToHost:self.HOST onPort:self.PORT withTimeout:self.CONNECT_TIME_OUT error:&error ];
            if(isSuccess)
            {
                NSLog(@"socket 可以连接");
            }else
            {
                NSLog(@"socket 不能连接 error = %@",error);
            }
        }else{
            [self cutOffSocket];
            [self connectToHost:self.HOST onPort:self.PORT];
            
        }
    }
}

//停止连接
-(void)cutOffSocket
{
    if([self.heartTimer isValid])
        [self.heartTimer invalidate];
    [self.socket disconnect];
    [self clearData];
    self.socketState = SocketOfflineByUser;
    
}

// 心跳连接
-(void)checkLongConnectByServe{
    // 向服务器发送固定可是的消息，来检测长连接
    if(self.heartCommand)
        [self writeCommand:self.heartCommand withTag:HeartTag];
}

//写数据 带心跳包验证
- (void)writeCommand:(TCPCommand *)tcpCommand{
    if(!self.socket.isConnected){
        [self connectToHost:self.HOST onPort:self.PORT];
    }
    if(![self.tcpCommands containsObject:tcpCommand])
    {
        tcpCommand.tag = _tag++;
        [self.tcpCommands addObject:tcpCommand];
        
        //如果开启心跳检测 发送一个心跳包
        if(tcpCommand.isOpenHeartCheck && self.heartCommand)
        {
            [self writeCommand:self.heartCommand withTag:tcpCommand.tag];
        }
        else
        {
            [self writeCommand:tcpCommand withTag:tcpCommand.tag];
        }
    }
}

- (void)writeCommand:(TCPCommand *)tcpCommand withTag:(long)tag{
    [self.socket writeData:tcpCommand.paramsData withTimeout:tcpCommand.WRITE_TIME_OUT tag:tag];
}

//获取当前命令包
- (TCPCommand *)getCurCommand:(long)tag{
    TCPCommand *tcpCommand;
    if(tag == HeartTag)
    {
        tcpCommand = self.heartCommand;
    }
    else
    {
        for(TCPCommand *command in self.tcpCommands)
        {
            if(command.tag == tag)
            {
                if(command.bagID != 1)
                    tcpCommand = command;
                else if(command.bagID == 1)
                    tcpCommand = self.heartCommand;
                break;
            }
        }
    }
    return tcpCommand;
}



#pragma mark -  属性
- (GCDAsyncSocket *)socket{
    if(!_socket)
    {
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    return _socket;
}

- (NSMutableArray *)tcpCommands{
    if(!_tcpCommands)
    {
        _tcpCommands = [[NSMutableArray alloc] init];
    }
    return _tcpCommands;
}

- (NSMutableData *)responseData{
    if(!_responseData){
        _responseData = [[NSMutableData alloc] init];
    }
    return _responseData;
}

@end
