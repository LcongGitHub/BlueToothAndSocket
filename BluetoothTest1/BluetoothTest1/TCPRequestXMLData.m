//
//  TCPRequestXMLData.m
//  BluetoothTest1
//
//  Created by 9377 on 15/8/27.
//  Copyright (c) 2015年 9377. All rights reserved.
//

#import "TCPRequestXMLData.h"
#import "TCPUtils.h"
@implementation TCPRequestXMLData

+(NSArray *)heart{
    NSMutableArray *xmlArr = [[NSMutableArray alloc] init];
    [xmlArr addObject:@{@"action":@"CMD_TEST"}];
    return xmlArr;
}

+(NSArray *)regist{
    //注册
    
    //    [xmlDic setObject:@"CMD_REGISTER_IOS" forKey:@"action"];
    //    [xmlDic setObject:[NSString stringWithFormat:@"PHONE-IOS-%@",[TCPUtils getUUID]] forKey:@"serail"];
    //    [xmlDic setObject:@"0" forKey:@"departmentid"];
    //    [xmlDic setObject:@"0" forKey:@"auto"];
    //    [xmlDic setObject:[TCPUtils getIPAddress] forKey:@"ip"];
    //    [xmlDic setObject:[TCPUtils appVersion] forKey:@"version"];
    
    
    NSMutableArray *xmlArr = [[NSMutableArray alloc] init];
    [xmlArr addObject:@{@"action":@"CMD_REGISTER_IOS"}];
    [xmlArr addObject:@{@"serail":[NSString stringWithFormat:@"PHONE-IOS-%@",[TCPUtils getUUID]]}];
    [xmlArr addObject:@{@"departmentid":@"0"}];
    [xmlArr addObject:@{@"auto":@"0"}];
    [xmlArr addObject:@{@"ip":[TCPUtils getIPAddress]}];
    [xmlArr addObject:@{@"version":[TCPUtils appVersion]}];
    return xmlArr;
}

+(NSArray *)isRegistSucces{
//    //判断是否注册
//    NSMutableDictionary *xmlDic = [[NSMutableDictionary alloc] init];
//    [xmlDic setObject:@"root" forKey:@"__name"];
//    [xmlDic setObject:@"CMD_ISCERT_COMPUTER_IOS" forKey:@"action"];
//    [xmlDic setObject:[NSString stringWithFormat:@"PHONE-IOS-%@",[TCPUtils getUUID]] forKey:@"serail"];
//    return xmlDic;
    
    NSMutableArray *xmlArr = [[NSMutableArray alloc] init];
    [xmlArr addObject:@{@"action":@"CMD_ISCERT_COMPUTER_IOS"}];
    [xmlArr addObject:@{@"serail":[NSString stringWithFormat:@"PHONE-IOS-%@",[TCPUtils getUUID]]}];
    return xmlArr;
}

+(NSArray *)loginWithUsername:(NSString *)username pwd:(NSString *)password{
    //IOS登陆验证
//    NSMutableDictionary *xmlDic = [[NSMutableDictionary alloc] init];
//    [xmlDic setObject:@"root" forKey:@"__name"];
//    [xmlDic setObject:@"CMD_LOGIN_IOS" forKey:@"action"];
//    [xmlDic setObject:@"0" forKey:@"logintype"];
//    [xmlDic setObject:[NSString stringWithFormat:@"PHONE-IOS-%@",[TCPUtils getUUID]] forKey:@"serail"];
//    [xmlDic setObject:username forKey:@"username"];
//    [xmlDic setObject:password forKey:@"pwd"];
    
    NSMutableArray *xmlArr = [[NSMutableArray alloc] init];
    [xmlArr addObject:@{@"action":@"CMD_LOGIN_IOS"}];
    [xmlArr addObject:@{@"logintype":@"0"}];
    [xmlArr addObject:@{@"serail":[NSString stringWithFormat:@"PHONE-IOS-%@",[TCPUtils getUUID]]}];
    [xmlArr addObject:@{@"username":username}];
    [xmlArr addObject:@{@"pwd":password}];
    return xmlArr;
}

+(NSArray *)userInfo:(NSString *)username{
    //IOS获取用户信息
//    NSMutableDictionary *xmlDic = [[NSMutableDictionary alloc] init];
//    [xmlDic setObject:@"root" forKey:@"__name"];
//    [xmlDic setObject:@"CMD_GET_USERINFO_IOS" forKey:@"action"];
//    [xmlDic setObject:[NSString stringWithFormat:@"PHONE-IOS-%@",[TCPUtils getUUID]] forKey:@"serail"];
//    [xmlDic setObject:username forKey:@"username"];
//    return xmlDic;
    
    NSMutableArray *xmlArr = [[NSMutableArray alloc] init];
    [xmlArr addObject:@{@"action":@"CMD_GET_USERINFO_IOS"}];
    [xmlArr addObject:@{@"serail":[NSString stringWithFormat:@"PHONE-IOS-%@",[TCPUtils getUUID]]}];
    [xmlArr addObject:@{@"username":username}];
    return xmlArr;
}

+(NSArray *)departMentInfo:(NSString *)username{
    //IOS获取部门信息
//    NSMutableDictionary *xmlDic = [[NSMutableDictionary alloc] init];
//    [xmlDic setObject:@"root" forKey:@"__name"];
//    [xmlDic setObject:@"CMD_GET_DEPART_SIMPLE_INFO_IOS" forKey:@"action"];
//    [xmlDic setObject:[NSString stringWithFormat:@"PHONE-IOS-%@",[TCPUtils getUUID]] forKey:@"serail"];
//    [xmlDic setObject:username forKey:@"username"];
//    return xmlDic;
    
    NSMutableArray *xmlArr = [[NSMutableArray alloc] init];
    [xmlArr addObject:@{@"action":@"CMD_GET_DEPART_SIMPLE_INFO_IOS"}];
    [xmlArr addObject:@{@"serail":[NSString stringWithFormat:@"PHONE-IOS-%@",[TCPUtils getUUID]]}];
    [xmlArr addObject:@{@"username":username}];
    return xmlArr;
}

+(NSArray *)loginOut:(NSString *)username{
    //注销
//    NSMutableDictionary *xmlDic = [[NSMutableDictionary alloc] init];
//    [xmlDic setObject:@"root" forKey:@"__name"];
//    [xmlDic setObject:@"CMD_LOGINOUT_IOS" forKey:@"action"];
//    [xmlDic setObject:[NSString stringWithFormat:@"PHONE-IOS-%@",[TCPUtils getUUID]] forKey:@"serail"];
//    [xmlDic setObject:username forKey:@"username"];
//    return xmlDic;
    
    NSMutableArray *xmlArr = [[NSMutableArray alloc] init];
    [xmlArr addObject:@{@"action":@"CMD_LOGINOUT_IOS"}];
    [xmlArr addObject:@{@"serail":[NSString stringWithFormat:@"PHONE-IOS-%@",[TCPUtils getUUID]]}];
    [xmlArr addObject:@{@"username":username}];
    return xmlArr;
}

@end
