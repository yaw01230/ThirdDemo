//
//  DemoTableViewController.m
//  TreeTableView
//
//  Created by mayan on 2018/5/11.
//  Copyright © 2018年 mayan. All rights reserved.
//

#import "DemoTableViewController.h"
#import "MBProgressHUD.h"

@interface DemoTableViewController () <MYTreeTableViewControllerParentClassDelegate>

@end

@implementation DemoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.classDelegate = self;
    
    // 创建 [提交] 和 [全选] 按钮
    UIBarButtonItem *commitItem = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(commitItemClick)];
    UIBarButtonItem *allCheckItem = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(allCheckItemClick)];
    UIBarButtonItem *allExpandItem = [[UIBarButtonItem alloc] initWithTitle:@"全部展开" style:UIBarButtonItemStylePlain target:self action:@selector(allExpandItemClick)];
    self.navigationItem.rightBarButtonItems = @[commitItem, allCheckItem, allExpandItem];

    // 请求数据
    [self requestData];
}

// 点击右上角 提交
- (void)commitItemClick {
    [self prepareCommit];
}

// 点击右上角 全选
- (void)allCheckItemClick {
    [self checkAllItem:YES];
}

// 点击右上角 全部展开
- (void)allExpandItemClick {
    [self expandAllItem:YES];
}

- (void)requestData {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"获取数据";
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{

        // 获取两种数据，二选一
//        self.manager = [self getManagerOfCraft];
        self.manager = [self getManagerOfCity];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
    });
}

- (MYTreeTableManager *)getManagerOfCraft {
    
    // 获取数据并创建树形结构
    NSData *JSONData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Resource" ofType:@"json"]];
    NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:nil];

    NSMutableSet *items = [NSMutableSet set];
    for (NSDictionary *data in dataArray) {

        MYTreeItem *item = [[MYTreeItem alloc] initWithName:data[@"name"]
                                                         ID:[NSString stringWithFormat:@"%@", data[@"id"]]
                                                   parentID:[NSString stringWithFormat:@"%@", data[@"pid"]]
                                                    orderNo:[NSString stringWithFormat:@"%@", data[@"order_no"]]
                                                       type:data[@"type"]
                                                     isLeaf:[data[@"type"] isEqualToString:@"ControlPoint"]
                                                       data:data];
        [items addObject:item];
    }

    // ExpandLevel 为 0 全部折叠，为 1 展开一级，以此类推，为 NSIntegerMax 全部展开
    MYTreeTableManager *manager = [[MYTreeTableManager alloc] initWithItems:items andExpandLevel:0];

    return manager;
}

- (MYTreeTableManager *)getManagerOfCity {
    
    // 获取数据并创建树形结构
    NSData *JSONData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cityResource" ofType:@"json"]];
    NSArray *provinceArray = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:nil];
    
    NSMutableSet *items = [NSMutableSet set];
    
    // 1. 遍历省份
    [provinceArray enumerateObjectsUsingBlock:^(NSDictionary *province, NSUInteger idx, BOOL * _Nonnull stop) {
        
        MYTreeItem *provinceItem = [[MYTreeItem alloc] initWithName:province[@"name"]
                                                                 ID:province[@"code"]
                                                           parentID:nil
                                                            orderNo:[NSString stringWithFormat:@"%lu", (unsigned long)idx]
                                                               type:@"province"
                                                             isLeaf:NO
                                                               data:province];
        [items addObject:provinceItem];
        
        // 2. 遍历城市
        NSArray *cityArray = province[@"children"];
        [cityArray enumerateObjectsUsingBlock:^(NSDictionary *city, NSUInteger idx, BOOL * _Nonnull stop) {
            
            MYTreeItem *cityItem = [[MYTreeItem alloc] initWithName:city[@"name"]
                                                                 ID:city[@"code"]
                                                           parentID:provinceItem.ID
                                                            orderNo:[NSString stringWithFormat:@"%lu", (unsigned long)idx]
                                                               type:@"city"
                                                             isLeaf:NO
                                                               data:city];
            [items addObject:cityItem];
            
            // 3. 遍历区
            NSArray *districtArray = city[@"children"];
            [districtArray enumerateObjectsUsingBlock:^(NSDictionary *district, NSUInteger idx, BOOL * _Nonnull stop) {
                
                MYTreeItem *districtItem = [[MYTreeItem alloc] initWithName:district[@"name"]
                                                                         ID:district[@"code"]
                                                                   parentID:cityItem.ID
                                                                    orderNo:[NSString stringWithFormat:@"%lu", (unsigned long)idx]
                                                                       type:@"district"
                                                                     isLeaf:YES
                                                                       data:district];
                [items addObject:districtItem];
            }];
        }];
    }];
    
    // ExpandLevel 为 0 全部折叠，为 1 展开一级，以此类推，为 NSIntegerMax 全部展开
    MYTreeTableManager *manager = [[MYTreeTableManager alloc] initWithItems:items andExpandLevel:NSIntegerMax];
    
    return manager;
}


#pragma mark - MYTreeTableViewControllerParentClassDelegate

- (void)refreshTableViewController:(MYTreeTableViewController *)tableViewController {
    [self requestData];
}

- (void)tableViewController:(MYTreeTableViewController *)tableViewController checkItems:(NSArray<MYTreeItem *> *)items {
    
    // 这里加一个隔离带目的是可以在这里做出个性化操作，然后再将数据传出
    if ([self.delegate respondsToSelector:@selector(tableViewController:checkItems:)]) {
        [self.delegate tableViewController:self checkItems:items];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchBarDidBeginEditingInTableViewController:(MYTreeTableViewController *)tableViewController {
    NSLog(@"点击了搜索栏");
}

- (void)tableViewController:(MYTreeTableViewController *)tableViewController didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"点击了第 %ld 行", (long)indexPath.row);
}

- (void)tableViewController:(MYTreeTableViewController *)tableViewController didSelectCheckBoxRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"点击了第 %ld 行的 checkbox", (long)indexPath.row);
}

@end
