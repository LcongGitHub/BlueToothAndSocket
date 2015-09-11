//
//  ModifyPsdViewController.m
//  BluetoothTest1
//
//  Created by 9377 on 15/8/19.
//  Copyright (c) 2015年 9377. All rights reserved.
//

#import "ModifyPsdViewController.h"
#import "BluetoothCentral.h"
@interface ModifyPsdViewController ()
@end

@implementation ModifyPsdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showBack];
    self.title = @"修改密码";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBluetoothValue:) name:@"BluetoothNotify" object:nil];

    // Do any additional setup after loading the view.
}

- (void)updateBluetoothValue:(NSNotification *)notify{
    NSDictionary *dic = [notify userInfo];
    NSLog(@"dic22 = %@",dic);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*

#pragma mark - Navigation

// In a storyboard-based application, you will of®ten want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//十六進位字串轉bytes
-(NSData *) hexStrToNSData:(NSString *)hexStr
{
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= hexStr.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* ch = [hexStr substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:ch];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

//十六進位字串轉bytes
-(NSData *)hexStrToNSData1:(NSString *)hexStr
{
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= hexStr.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* ch = [hexStr substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:ch];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

-(NSData *)hexStrToNSData:(NSString *)data withSize:(NSInteger)size
{
    int add = size*2 - data.length;
    if (add > 0) {
        NSString* tmp = [[NSString string] stringByPaddingToLength:add withString:@"0" startingAtIndex:0];
        data = [tmp stringByAppendingString:data];
    }
    return [self hexStrToNSData1:data];
}

-(NSData *) LongToNSData:(long long)data
{
    Byte *buf = (Byte*)malloc(3);
    for (int i=2; i>=0; i--) {
        buf[i] = data & 0x0000ff;
        data = data >> 3;
    }
    NSData *result =[NSData dataWithBytes:buf length:3];
    return result;
}

- (NSData *)dataFromString:(NSString *)string
{
        const char *buf = [string UTF8String];
        NSMutableData *data = [NSMutableData data];
        if (buf)
        {
            uint32_t len = strlen(buf);
            char singleNumberString[3] = {'\0', '\0', '\0'};
            uint32_t singleNumber = 0;
            for(uint32_t i = 0 ; i < len; i+=2)
            {
                if ( ((i+1) < len) && isxdigit(buf[i]) && (isxdigit(buf[i+1])) )
                {
                    singleNumberString[0] = buf[i];
                    singleNumberString[1] = buf[i + 1];
                    sscanf(singleNumberString, "%x", &singleNumber);
                    uint8_t tmp = (uint8_t)(singleNumber & 0x000000FF);
                    [data appendBytes:(void *)(&tmp)length:1];
                }
                else
                {
                    break;
                }
            }
        }
    return data;
}
- (IBAction)bingEvent:(id)sender {
    
    BluetoothCommand *command = [[BluetoothCommand alloc] init];
    command.serviceUUIDString = kServiceUUIDFFF0;
    command.characteristicUUIDString = kCharacteristicUUIDFFF1;
    command.executeType = 1;

//    unsigned char send1[3];
//    send1[0] = 0xa8;
//    send1[1] = 0x00;
//    send1[2] = 0xa8;
    
    unsigned char a;
    a = 0XA80000;
    Byte byte = (Byte)a;
    NSData *da = [NSData dataWithBytes:&byte length:3];
    
//    NSData *send_data =[self dataFromString:@"a912540000"];
    command.commandData = da;
    [[BluetoothCentral shareInstance] execute:command];

}


- (IBAction)modifyEvent:(id)sender {
    BluetoothCommand *command = [[BluetoothCommand alloc] init];
    command.serviceUUIDString = kServiceUUIDFFF0;
    command.characteristicUUIDString = kCharacteristicUUIDFFF1;
    command.executeType = 1;

    [[BluetoothCentral shareInstance] execute:command];
}
@end
