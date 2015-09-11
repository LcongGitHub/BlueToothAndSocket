//
//  MainViewController.m
//  BluetoothTest1
//
//  Created by 9377 on 15/8/24.
//  Copyright (c) 2015年 9377. All rights reserved.
//

#import "MainViewController.h"
#import "ClientViewController.h"
#import "CentralViewController.h"

@interface MainViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.dataArray addObject:@"蓝牙"];
    [self.dataArray addObject:@"TCP Socket"];

    // Do any additional setup after loading the view.
}

#pragma mark - property
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

#pragma mark - UITableView 
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
        {
            CentralViewController *vc = [[CentralViewController alloc] init];
            UIStoryboard *board = [UIStoryboard storyboardWithName: @"Main" bundle: nil];
            vc = [board instantiateViewControllerWithIdentifier: @"CentralViewController"];
            [self.navigationController pushViewController:vc animated:YES];

        }
            break;
            case 1:
        {
            ClientViewController *vc = [[ClientViewController alloc] init];
            UIStoryboard *board = [UIStoryboard storyboardWithName: @"Main" bundle: nil];
            vc = [board instantiateViewControllerWithIdentifier: @"ClientViewController"];
            [self.navigationController pushViewController:vc animated:YES];

        }
            break;

        default:
            break;
    }
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
