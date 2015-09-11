//
//  ClientViewController.m
//  BluetoothTest1
//
//  Created by 9377 on 15/8/24.
//  Copyright (c) 2015年 9377. All rights reserved.
//

#import "ClientViewController.h"
#import "TCPClient.h"
#import "TCPRequestXMLData.h"
#import <XMLDictionary.h>
#import "KWOfficeApi.h"

@interface ClientViewController ()<UIPickerViewDataSource,UIPickerViewDelegate>
{
    NSArray *_secretKeyArr;
    NSInteger _curFileType;
    NSString *_curSecretKey;
}

@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation ClientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showBack];
    //测试用
//    _secretKeyArr = @[@{@"key":@"EA12824C48B60799"},@{@"key":@"No key"}];
//    _curSecretKey = [[_secretKeyArr objectAtIndex:0] objectForKey:@"key"];
    
  
    self.dataArray = [[NSMutableArray alloc] init];
    [self.dataArray addObject:@"登录"];
    
    
    self.title = @"Client 客户端";
    //设置心跳
    TCPCommand *heartCommand = [[TCPCommand alloc] init];
    heartCommand.xmlArray = [TCPRequestXMLData heart];
    heartCommand.bagID = 1;
    [[TCPClient shareInstance] setHeartCommand:heartCommand];
    
    [[TCPClient shareInstance] setDidFinishBlock:^(GCDAsyncSocket *socket, NSDictionary *result, NSError *error) {
        if(result){
            
            
            switch ([[result objectForKey:@"bagID"] integerValue]) {
                case 1:
                    
                    break;
                case 2:{
                    //绑定
                    if([[result objectForKey:@"status"] integerValue] == 0){
                        [super showTextHUD:[result objectForKey:@"info"]];
                    }else{
                        TCPCommand *command1 = [[TCPCommand alloc] init];
                        command1.xmlArray = [TCPRequestXMLData loginWithUsername:self.username.text pwd:self.passwrod.text];
                        command1.bagID = 4;
                        command1.isOpenHeartCheck = YES;
                        
                        [[TCPClient shareInstance] writeCommand:command1];
                    }
                }
                    break;
                case 3:{
                    if([[result objectForKey:@"status"] integerValue] == 0){
                        //未绑定情况 去绑定
                        TCPCommand *command = [[TCPCommand alloc] init];
                        command.xmlArray = [TCPRequestXMLData regist];
                        command.bagID = 2;
                        command.isOpenHeartCheck = YES;
                        [[TCPClient shareInstance] writeCommand:command];
                    }else{
                        TCPCommand *command1 = [[TCPCommand alloc] init];
                        command1.xmlArray = [TCPRequestXMLData loginWithUsername:self.username.text pwd:self.passwrod.text];
                        command1.bagID = 4;
                        command1.isOpenHeartCheck = YES;
                        
                        [[TCPClient shareInstance] writeCommand:command1];
                    }
                }
                    break;
                case 4:{
                    [super showTextHUD:[result objectForKey:@"info"]];
                    if([[result objectForKey:@"status"] integerValue] == 1){
                        [self.dataArray removeAllObjects];
                        [self.dataArray addObject:@"获取部门信息"];
                        [self.dataArray addObject:@"注销"];
                        [self.tableView reloadData];
                    }
                }
                    break;
                case 5:{
                    
                }
                    break;
                case 6:{

                    if([result objectForKey:@"record"]){
                        [self.dataArray removeAllObjects];
                        [self.dataArray addObject:@"获取部门信息"];
                        [self.dataArray addObject:@"注销"];
                        [self.dataArray addObject:@"欢迎使用WPS.doc"];
                        [self.dataArray addObject:@"贷款计算器.xls"];
                        [self.dataArray addObject:@"休闲时光.ppt"];
                        [self.tableView reloadData];
                        
                        _secretKeyArr = [result objectForKey:@"record"];
                        
                        for(NSDictionary *d in _secretKeyArr){
                            if([[d objectForKey:@"key"] length] == 16){
                                _curSecretKey = [d objectForKey:@"key"];
                            }
                        }
                        
                       
                    }
                    
                }
                    break;
                case 7:{
                        [self.dataArray removeAllObjects];
                        [self.dataArray addObject:@"登录"];
                        [self.tableView reloadData];
                    
                }break;
                default:
                    
                break;
            }
            
            
        }else if(error){
            [super showTextHUD:[error localizedDescription]];
        }
    }];


    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //判断是否绑定手机
   

}

#pragma mark - TableViewDelegata & TableViewDataSource
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *str = [_dataArray objectAtIndex:indexPath.row];
    if([str isEqualToString:@"登录"]){
        [[TCPClient shareInstance] connectToHost:self.hostTF.text onPort:[self.portTF.text integerValue]];//连接

        TCPCommand *command = [[TCPCommand alloc] init];
        command.xmlArray = [TCPRequestXMLData isRegistSucces];
        command.bagID = 3;
        command.isOpenHeartCheck = YES;
        [[TCPClient shareInstance] writeCommand:command];
        
       
    }else if([str isEqualToString:@"获取部门信息"]){
        TCPCommand *command = [[TCPCommand alloc] init];
        command.xmlArray = [TCPRequestXMLData departMentInfo:self.username.text];
        command.bagID = 6;
        command.isOpenHeartCheck = YES;
        [[TCPClient shareInstance] writeCommand:command];
        
    }else if([str isEqualToString:@"注销"]){
        TCPCommand *command = [[TCPCommand alloc] init];
        command.xmlArray = [TCPRequestXMLData loginOut:self.username.text];
        command.bagID = 7;
        command.isOpenHeartCheck = YES;
        [[TCPClient shareInstance] writeCommand:command];
    }else if([str isEqualToString:@"欢迎使用WPS.doc"]){
        [self openFile:0];
    }else if([str isEqualToString:@"贷款计算器.xls"]){
        [self openFile:1];
    }else if([str isEqualToString:@"休闲时光.ppt"]){
        [self openFile:2];
    }
}

- (void)openFile:(NSInteger)type{
    switch (_curFileType) {
        case 0:
        {
            NSDictionary *userInfo = @{@"key":_curSecretKey,@"fileName":@"欢迎使用WPS.doc"};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RunWpsAppNotifi" object:nil userInfo:userInfo];
        }break;
            
        case 1:{
            NSDictionary *userInfo = @{@"key":_curSecretKey,@"fileName":@"贷款计算器.xls"};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RunWpsExcelAppNotifi" object:nil userInfo:userInfo];
        }break;
            
        case 2:{
            NSDictionary *userInfo = @{@"key":_curSecretKey,@"fileName":@"休闲时光.ppt"};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RunWpsPPTAppNotifi" object:nil userInfo:userInfo];
        }break;
            
        default:
            break;
    }
}

#pragma mark - picker delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if(_secretKeyArr)
        return _secretKeyArr.count;
    else
        return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [[_secretKeyArr objectAtIndex:row] objectForKey:@"key"];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    _curSecretKey = [[_secretKeyArr objectAtIndex:row] objectForKey:@"key"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
