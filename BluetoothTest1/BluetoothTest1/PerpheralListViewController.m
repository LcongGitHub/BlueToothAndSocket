//
//  PerpheralListViewController.m
//  BluetoothTest1
//
//  Created by 9377 on 15/8/18.
//  Copyright (c) 2015年 9377. All rights reserved.
//

#import "PerpheralListViewController.h"
//#import "BluetoothManager.h"

@interface PerpheralListViewController ()

@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation PerpheralListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showBack];
    self.title = @"附近的蓝牙设备";
    [self searchList];

    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)searchList{
    __weak typeof(self) weakSelf = self;
    [[BluetoothCentral shareInstance] setSearchPeripheralBlock:^(NSMutableArray *peripherals) {
        [weakSelf.dataArray removeAllObjects];
        [weakSelf.dataArray addObjectsFromArray:peripherals];
        [weakSelf.tableView reloadData];
    }];
    [[BluetoothCentral shareInstance] searchPeripheral];
    
}

- (NSMutableArray *)dataArray{
    if(!_dataArray){
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"PeripheralUITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.text = [[_dataArray objectAtIndex:indexPath.row] name];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [[BluetoothCentral shareInstance] setDidConnectPeripheralBlock:^(BOOL didConnected) {
        
        if(didConnected){
            
            if(_didSelectedPeripheral){
                _didSelectedPeripheral([_dataArray objectAtIndex:indexPath.row]);
                [self.navigationController popViewControllerAnimated:YES];
            }
            
            
            
        }
        
    }];
    [[BluetoothCentral shareInstance] connectPeripheral:[_dataArray objectAtIndex:indexPath.row]];
    
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
