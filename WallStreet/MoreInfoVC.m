//
//  MoreInfoVC.m
//  WallStreet
//
//  Created by qingyun on 16/4/19.
//  Copyright © 2016年 qingyun. All rights reserved.
//

#import "MoreInfoVC.h"

#import "AFHTTPSessionManager.h"

#import "MJRefresh.h"

#import "InfoModel.h"
#import "InfoCellOne.h"

#import "DetailVC.h"

@interface MoreInfoVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *infoArr;

@property (nonatomic, assign) NSInteger pageIndex;

@end

@implementation MoreInfoVC

static NSString *cellIdentifier = @"cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 100.f;
    [self.view addSubview:_tableView];
    
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([InfoCellOne class]) bundle:nil] forCellReuseIdentifier:cellIdentifier];
    
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _pageIndex = 1;
        [self loadData];
    }];
    
    _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        _pageIndex++;
        [self loadData];
    }];
    
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
    
}

- (void)loadData {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSDictionary *parameter = @{@"channel":_channel,@"page":@(_pageIndex)};
    
    [manager GET:@"http://api.wallstreetcn.com/v2/mobile-articles?&device=android&accept=article&_eva_t=1461145954" parameters:parameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        
        NSDictionary *resultDict = (NSDictionary *)responseObject;
        NSArray *resultArr = resultDict[@"results"];
        
        _infoArr = [NSMutableArray array];
        [resultArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            InfoModel *model = [InfoModel modelWithDictionary:(NSDictionary *)obj];
            [_infoArr addObject:model];
        }];
        
        if ([_tableView.mj_header isRefreshing]) {
            [_tableView.mj_header endRefreshing];
        }
        if ([_tableView.mj_footer isRefreshing]) {
            [_tableView.mj_footer endRefreshing];
        }
        
        [_tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _infoArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    InfoCellOne *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.infoModel = _infoArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    InfoModel *model = _infoArr[indexPath.row];
    
    DetailVC *web = [self.storyboard instantiateViewControllerWithIdentifier:@"WebVC"];
    web.Id = model.Id;
    //    web.url = model.url;
    
    [self.navigationController pushViewController:web animated:NO];
}

@end
