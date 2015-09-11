//
//  CentralViewController.m
//  BluetoothTest1
//
//  Created by 9377 on 15/8/18.
//  Copyright (c) 2015年 9377. All rights reserved.
//

#import "CentralViewController.h"
#import "PerpheralListViewController.h"
#import "ModifyPsdViewController.h"
#import "BluetoothCentral.h"
#import "ModifyNameViewController.h"

@interface CentralViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableString *result;
@end

@implementation CentralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showBack];
    self.title = @"充电宝Demo";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBluetoothValue:) name:@"BluetoothNotify" object:nil];
    [self.dataArray addObject:@"选择设备"];
    [self.dataArray addObject:@"检测电压"];
    [self.dataArray addObject:@"修改充电宝密码"];
    [self.dataArray addObject:@"打开快速放电"];
    [self.dataArray addObject:@"打开慢速放电"];
    [self.dataArray addObject:@"关闭放电"];
    [self.dataArray addObject:@"查询放电时间"];
    [self.dataArray addObject:@"查询放电状态"];
    [self.dataArray addObject:@"修改充电宝名称"];
    [self.dataArray addObject:@"读取绑定密码反馈"];

    self.result = [[NSMutableString alloc] init];
    
    // Do any additional setup after loading the view.
}
- (NSMutableArray *)dataArray{
    if(!_dataArray){
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//#pragma mark - TableViewDelegata & TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.text = [_dataArray objectAtIndex:indexPath.row];
    return cell;
}

- (void)updateBluetoothValue:(NSNotification *)notify{
    NSDictionary *dic = [notify userInfo];
    NSLog(@"dic111= %@",dic);
    CBCharacteristic *c = [dic objectForKey:@"characteristic"];
    if(![c.UUID.UUIDString isEqualToString:kCharacteristicUUIDFFF2])
    [self.result appendString:[NSString stringWithFormat:@"监听通知结果  %@ -- %@\n",c.UUID.UUIDString,c.value]];
    _logView.text = self.result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;
    switch (indexPath.row) {
        case 0:{
            PerpheralListViewController *vc = [[PerpheralListViewController alloc] init];

            UIStoryboard *board = [UIStoryboard storyboardWithName: @"Main" bundle: nil];
            vc = [board instantiateViewControllerWithIdentifier: @"PerpheralListViewController"];
            //Bring to detail page
            [vc setDidSelectedPeripheral:^(CBPeripheral *peripheral) {
                NSLog(@"选中的外设 = %@",peripheral);
                [weakSelf.dataArray replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"当前连接 %@",peripheral.name]];
                [weakSelf.tableView reloadData];
                
//                BluetoothCommand *command = [[BluetoothCommand alloc] init];
//                command.serviceUUIDString = kServiceUUIDFFF0;
//                command.characteristicUUIDString = kCharacteristicUUIDFFFA;
//                command.executeType = 2;
//                
//                [[BluetoothCentral shareInstance] execute:command];
////
//                BluetoothCommand *command1 = [[BluetoothCommand alloc] init];
//                command.serviceUUIDString = kServiceUUIDFFF0;
//                command.characteristicUUIDString = kCharacteristicUUIDFFF4;
//                command.executeType = 2;
//                
//                [[BluetoothCentral shareInstance] execute:command1];

            }];
            [self.navigationController pushViewController:vc animated:YES];

        }
            break;
        case 1:{
          
            BluetoothCommand *command = [[BluetoothCommand alloc] init];
            command.serviceUUIDString = kServiceUUIDFFF0;
            command.characteristicUUIDString = kCharacteristicUUIDFFF2;
            command.executeType = 0;
            [[BluetoothCentral shareInstance] execute:command];

        }
            break;
        case 2:{//修改密码
            ModifyPsdViewController *vc = [[ModifyPsdViewController alloc] init];
            UIStoryboard *board = [UIStoryboard storyboardWithName: @"Main" bundle: nil];
            vc = [board instantiateViewControllerWithIdentifier: @"ModifyPsdViewController"];
            
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 3:{//打开快速放电
            Byte dataArr[1];
            dataArr[0]=0xa1;
            NSData * myData = [NSData dataWithBytes:dataArr length:1];
        
            BluetoothCommand *command = [[BluetoothCommand alloc] init];
            command.serviceUUIDString = kServiceUUIDFFF0;
            command.characteristicUUIDString = kCharacteristicUUIDFFF1;
            command.executeType = 1;
            command.commandData = myData;

            [[BluetoothCentral shareInstance] execute:command];
        }
            break;
        case 4:{//打开慢速放电
            Byte dataArr[1];
            dataArr[0]=0xa2;
            NSData * myData = [NSData dataWithBytes:dataArr length:1];
            BluetoothCommand *command = [[BluetoothCommand alloc] init];
            command.serviceUUIDString = kServiceUUIDFFF0;
            command.characteristicUUIDString = kCharacteristicUUIDFFF1;
            command.executeType = 1;
            command.commandData = myData;
            
            [[BluetoothCentral shareInstance] execute:command];

        }
            break;
        case 5:{//关闭放电
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
            break;
        case 6:{//查询放电时间
            Byte dataArr[1];
            dataArr[0]=0xa5;
            NSData * myData = [NSData dataWithBytes:dataArr length:1];

            BluetoothCommand *command = [[BluetoothCommand alloc] init];
            command.serviceUUIDString = kServiceUUIDFFF0;
            command.characteristicUUIDString = kCharacteristicUUIDFFF1;
            command.executeType = 1;
            command.commandData = myData;
            NSLog(@"select charge time data = %@",myData);

            [[BluetoothCentral shareInstance] execute:command];
        }
            break;
        case 7:{//查询放电状态
            Byte dataArr[1];
            dataArr[0]=0xa3;
            NSData * myData = [NSData dataWithBytes:dataArr length:1];
            BluetoothCommand *command = [[BluetoothCommand alloc] init];
            command.serviceUUIDString = kServiceUUIDFFF0;
            command.characteristicUUIDString = kCharacteristicUUIDFFF1;
            command.executeType = 1;
            command.commandData = myData;
            
            [[BluetoothCentral shareInstance] execute:command];
        }
            break;
        case 8:{//修改名称
            ModifyNameViewController *vc = [[ModifyNameViewController alloc] init];
            UIStoryboard *board = [UIStoryboard storyboardWithName: @"Main" bundle: nil];
            vc = [board instantiateViewControllerWithIdentifier: @"ModifyNameViewController"];
            
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 9:{//设置FFFA监听
            BluetoothCommand *command = [[BluetoothCommand alloc] init];
            command.serviceUUIDString = kServiceUUIDFFF0;
            command.characteristicUUIDString = kCharacteristicUUIDFFFA;
            command.executeType = 2;
            
            [[BluetoothCentral shareInstance] execute:command];
        }
            break;
        default:
            break;
    }
   
    
}



@end
