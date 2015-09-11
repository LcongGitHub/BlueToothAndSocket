//
//  TCPRequestXMLData.h
//  BluetoothTest1
//
//  Created by 9377 on 15/8/27.
//  Copyright (c) 2015年 9377. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCPRequestXMLData : NSObject

+(NSArray *)heart;
+(NSArray *)regist;
+(NSArray *)isRegistSucces;
+(NSArray *)loginWithUsername:(NSString *)username pwd:(NSString *)password;
+(NSArray *)userInfo:(NSString *)username;
+(NSArray *)departMentInfo:(NSString *)username;
+(NSArray *)loginOut:(NSString *)username;


@end
