//
//  TCPUtils.m
//  BluetoothTest1
//
//  Created by 9377 on 15/8/27.
//  Copyright (c) 2015年 9377. All rights reserved.
//

#import "TCPUtils.h"
#import <UIKit/UIDevice.h>
#include <ifaddrs.h>
#include <arpa/inet.h>

@implementation TCPUtils


+ (NSString *)getUUID{
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

+ (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

+ (NSString *)systemVersion{
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *)appVersion{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
//    // app名称
//    
//    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
//    
    // app版本
    
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    return app_Version;
}



@end
