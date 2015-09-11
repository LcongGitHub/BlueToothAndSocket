//
//  NSData+AES.h
//  BluetoothTest1
//
//  Created by 9377 on 15/9/2.
//  Copyright (c) 2015年 9377. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NSStringCode NSUTF8StringEncoding

@interface NSData (AES)

- (NSData *)AESEncryptWithKey:(NSString *)key;   //加密
- (NSData *)AESDecryptWithKey:(NSString *)key;   //解密

@end
