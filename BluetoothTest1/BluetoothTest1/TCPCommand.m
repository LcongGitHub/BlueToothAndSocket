//
//  TCPCommand.m
//  BluetoothTest1
//
//  Created by 9377 on 15/8/28.
//  Copyright (c) 2015年 9377. All rights reserved.
//

#import "TCPCommand.h"
#import <GDataXMLNode.h>

@implementation TCPCommand

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.WRITE_TIME_OUT = -1;
        self.READ_TIME_OUT = -1;
        self.MAX_BUFFER = 1024;
        self.tag = 0;
    }
    return self;
}


- (NSData *)paramsData{
    if(!_paramsData){
        _paramsData = [[NSMutableData alloc] init];
    }
    if(_paramsData)
    _paramsData = [self testData];
    return _paramsData;
}

- (NSData *)testData{
    //ID
    NSData *bagIDData = [NSData dataWithBytes:&_bagID length:4];
    
    //命令类型
    NSUInteger comType = 107;
    NSData *comTypeData = [NSData dataWithBytes:&comType length:2];
    
    GDataXMLElement *root = [GDataXMLElement elementWithName:@"root"];
    for(int i = 0; i < self.xmlArray.count; i ++){
        NSDictionary *d = [self.xmlArray objectAtIndex:i];
        NSString *key = [[d allKeys] lastObject];
        GDataXMLElement *element = [GDataXMLElement elementWithName:key stringValue:[d objectForKey:key]];
        [root addChild:element];
    }
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithRootElement:root];
    [doc setCharacterEncoding:@"UTF-8"];
    [doc setVersion:@"1.0"];
    NSData *xmlData = [doc XMLData];
    
    NSString *str = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSUInteger xmlLength = [xmlData length];
    NSData *xmlLengthData = [NSData dataWithBytes:&xmlLength length:4];
    
    //包类型
    NSUInteger bagType = 2147483648;
    NSData *bagTypeData = [NSData dataWithBytes:&bagType length:4];
    
    //发送数据终极组合
    NSMutableData *paramsData = [[NSMutableData alloc] init];
    [paramsData appendData:bagIDData];
    [paramsData appendData:comTypeData];
    [paramsData appendData:xmlLengthData];
    [paramsData appendData:bagTypeData];
    [paramsData appendData:xmlData];
    
    NSLog(@"\n\n\n\n-----sendData------\n请求数据 BagID : \n%ld \n请求字符串str : \n%@",_bagID,str);
    return paramsData;
}


@end
