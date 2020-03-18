//
//  dataGridViewController.m
//  ZQDatagridComponentDemo
//
//  Created by zhiqing on 2019/3/6.
//  Copyright © 2019 zhiqing. All rights reserved.
//

#import "DataGridViewController.h"
#import "myDataGridView.h"
#import "ZQDataGridLeftTableViewCellModel.h"
#import "ZQDataGridHeadItemModel.h"
#import "CustomViewModel.h"
#import "LeftCellModel.h"

static NSInteger dataCount = 20;

@interface DataGridViewController ()
@property (nonatomic, strong) myDataGridView *dataGridView;

@end

@implementation DataGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.dataGridView];
}

#pragma -mark 表格事件处理
- (void)eventDealwithActionType:(ZQDataGridComponentClickType)type row:(NSInteger)row column:(NSInteger)column tagetView:(UIView *)tagetView{
    NSString * moudle = @"";
    if (type == ZQDataGridComponentClickTypeHead) {
        moudle = @"头部视图";
    }else if (type == ZQDataGridComponentClickTypeLeftTab){
        moudle = @"头部左侧列表";
        // 点击刷新 行高
        if (self.type == 6) {
            NSMutableArray * rowHeightArr = self.dataGridView.dataModel.rowHeightArr.mutableCopy;
            if ([rowHeightArr[row] isEqual:@(200)]) {
                rowHeightArr[row] = @(100);
            }else{
                rowHeightArr[row] = @(200);
            }
            self.dataGridView.dataModel.rowHeightArr = rowHeightArr.copy;
            [self.dataGridView reloadDataRow:row];
        }
    }else if (type == ZQDataGridComponentClickTypeRightTab){
        moudle = @"头部右侧列表";
    }
    
    NSLog(@"点击了 %@ 行号：%ld 列号：%ld  tagViewClass:%@",moudle,row,column,[tagetView class]);

}


#pragma -mark 组装表格数据模型
- (ZQDataGridComponentModel *)getDataModel{
    ZQDataGridComponentModel * dataModel = [[ZQDataGridComponentModel alloc]init];
    dataModel.firstRowHeight = 40.0f;
    dataModel.firstColumnWidth = 80.0f;
    dataModel.rowHeight = 70.0f;
    // 获取表格右侧表头数据
    ZQDataGridRightTableViewCellModel * headModel = [self getrightHeadModel];
    
    // 列宽数组
    NSMutableArray * columnWidthArray = [self getColumnWidthArray];
    
    // 行高数组
    NSMutableArray * rowHeightArray = [[NSMutableArray alloc]init];
    
    // 坐标数据模型数组
    NSMutableArray * leftTableDataArray = [[NSMutableArray alloc]init];
    // 右侧数据模型数组
    NSMutableArray * rowDataArray = [[NSMutableArray alloc]init];
    
    // 根据房间数构造需要的行数据
    for (int i = 0 ; i < dataCount; i++) {
        // 左侧列表数据
        if (self.type == 2) {
            LeftCellModel * model = [[LeftCellModel alloc]init];
            model.title = [NSString stringWithFormat:@"行表头 %d",i];
            model.subTitle = [NSString stringWithFormat:@"自定义 %d",i];
            [leftTableDataArray addObject:model];
        }else{
            ZQDataGridLeftTableViewCellModel * model = [[ZQDataGridLeftTableViewCellModel alloc]init];
            model.titleString = [NSString stringWithFormat:@"行表头 %d",i];
            [leftTableDataArray addObject:model];
        }
      
        
        // 右侧列表数据
        ZQDataGridRightTableViewCellModel * rowModel = [[ZQDataGridRightTableViewCellModel alloc]init];
        rowModel.numOfRowIndex = i;
        rowModel.numOfColumnNumIndex = 0;
        if (self.type == 3) {
            // 设置右侧每个单元格的类名，根据类名注册cell类型
            rowModel.collectionViewCellClass = @"CustomCollectionViewCell";
            // 设置右侧每个单元格设置数据时的方法签名
            rowModel.setDataMethodName = @"setCellModel:";
        }else{
            rowModel.collectionViewCellClass = @"NomalCollectionViewCell";
            rowModel.setDataMethodName = @"setItemModel:";
        }
        rowModel.itemModelArray = [self getItemModelArrayWithRowNum:i];
        if (self.type == 6) {  // 行高自定义
            if (i %2 == 0) {
                [rowHeightArray addObject:@(140)];
            }else{
                 [rowHeightArray addObject:@(70)];
            }
        }
        [rowDataArray addObject:rowModel];
    }
    
    dataModel.headDataModel = headModel;
    dataModel.leftTableDataArray = leftTableDataArray;
    dataModel.rowDataArray = rowDataArray;
    dataModel.columnWidthArray = columnWidthArray;
    dataModel.rowHeightArr = rowHeightArray;
    // 自定义左侧列表cell
    if (self.type == 2) {
        dataModel.leftTableViewCellClass = @"LeftTableViewCell";
        dataModel.setDataMethodName = @"setModel:";
    }
    return dataModel;
}

#pragma -mark 获取每一行中collocationView item 的小数据源
- (NSArray *)getItemModelArrayWithRowNum:(NSInteger)rowNum{
    NSMutableArray * itemArray = [[NSMutableArray alloc]init];
    for ( int i = 0; i < dataCount; i++) {
        
        if (self.type == 3) {
            CustomViewModel * itemModel = [[CustomViewModel alloc]init];
            itemModel.title = [NSString stringWithFormat:@"%ld-行 / %d-列",rowNum,i];
            NSString *imageString ;
            if (i % 3 == 0) {
                imageString = @"blue";
            }else if (i % 3 == 1){
                imageString = @"green";
            }else if (i % 3 == 2){
                imageString = @"yellow";
            }
            itemModel.image = imageString;
            [itemArray addObject:itemModel];
        }else{
            ZQDataGridLeftTableViewCellModel * itemModel = [[ZQDataGridLeftTableViewCellModel alloc]init];
            itemModel.numOfColumnNumIndex = i;
            itemModel.numOfRowIndex = rowNum;
            itemModel.titleString = [NSString stringWithFormat:@"%ld-行 / %d-列",rowNum,i];
            [itemArray addObject:itemModel];
        }
       
    }
    return itemArray;
}

#pragma -mark 获取每列的宽度
- (NSMutableArray *)getColumnWidthArray{
    NSMutableArray * array = [NSMutableArray new];
    for (int i = 0; i < dataCount; i++) {
        if (self.type == 1) { // 自定义每列宽度
            if (i % 2 == 0) {
                [array addObject:@(140.0)];
            }else{
                [array addObject:@(70.0)];
            }
        }else{
            [array addObject:@(70.0)];
        }
    }
    return array;
}

#pragma -mark h获取右侧头部的数据 其类型与右侧的 大cell 类型一致亦可自定义item
- (ZQDataGridRightTableViewCellModel *)getrightHeadModel{
    ZQDataGridRightTableViewCellModel * headDataModel = [[ZQDataGridRightTableViewCellModel alloc]init];
    headDataModel.collectionViewCellClass = @"ZQDataGridHeadItemCell";
    headDataModel.setDataMethodName = @"setItemModel:";
    headDataModel.itemModelArray = [self getHeadModelItemArray];
    return headDataModel;
}


#pragma -mark 获取表头数据
- (NSArray *)getHeadModelItemArray{
    NSMutableArray * itemArray = [[NSMutableArray alloc]init];
    for ( int i = 0; i < dataCount; i++) {
        ZQDataGridHeadItemModel * itemModel = [[ZQDataGridHeadItemModel alloc]init];
        itemModel.numOfColumnNumIndex = i;
        itemModel.titleString = [NSString stringWithFormat:@"列表头 %d",i];
        [itemArray addObject:itemModel];
    }
    return itemArray;
}

- (myDataGridView *)dataGridView{
    if (!_dataGridView) {
        _dataGridView = [[myDataGridView alloc]initWithFrame:CGRectMake(0, kSafeAreaTopHeight, self.view.width, self.view.height - kSafeAreaTopHeight - SafeAreaBottomHeight) dataSource:[self getDataModel]];
       
        Weak(self);
        _dataGridView.itemClick = ^(ZQDataGridComponentClickType type, NSInteger row, NSInteger column, UIView *tagetView) {
            [weakself eventDealwithActionType:type row:row column:column tagetView:tagetView];
        };
        
        if (self.type == 5) {
            
            _dataGridView.rightTableView.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
                NSLog(@"下拉刷新");
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakself.dataGridView.rightTableView.mj_header endRefreshing];
                });
            }];
            
            _dataGridView.rightTableView.mj_footer = [MJRefreshAutoGifFooter footerWithRefreshingBlock:^{
                NSLog(@"上拉加载");
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakself.dataGridView.rightTableView.mj_footer endRefreshingWithNoMoreData];
                });
            }];
            
            // 不让mj 自适应宽度
            _dataGridView.rightTableView.mj_header.autoresizingMask = UIViewAutoresizingNone;
             // 设置mj宽度
            _dataGridView.rightTableView.mj_header.mj_w = SCREEN_WIDTH;
            _dataGridView.rightTableView.mj_header.mj_x = -_dataGridView.dataModel.firstColumnWidth;
            
            _dataGridView.rightTableView.mj_footer.autoresizingMask = UIViewAutoresizingNone;
            _dataGridView.rightTableView.mj_footer.mj_w = SCREEN_WIDTH;
            _dataGridView.rightTableView.mj_footer.mj_x = -_dataGridView.dataModel.firstColumnWidth;
        }
        
        
    }
    return _dataGridView;
}
@end
