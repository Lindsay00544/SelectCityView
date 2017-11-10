//
//  CityController.m
//  BianLi
//
//  Created by 骆凡 on 16/6/23.
//  Copyright © 2016年 user. All rights reserved.
//

#import "CityController.h"
#import "ZYPinYinSearch.h"
#import "ChineseString.h"

#define Screen_Size       [UIScreen mainScreen].bounds.size
#define ScreenWidth       ([UIScreen mainScreen].bounds.size.width)
#define ScreenHeight      ([UIScreen mainScreen].bounds.size.height)
#define RGBCOLOR(r,g,b,a) [UIColor colorWithRed:(r) / 255.0f green:(g) / 255.0f blue:(b) / 255.0f alpha:(a)]
#define After9            (UIDevice.currentDevice.systemVersion.floatValue >= 9.0)
#define TextFontSize(a)   (After9?[UIFont fontWithName:@"PingFangSC-Light" size:a]:[UIFont systemFontOfSize:a])


@interface CityController ()<UITableViewDataSource,UITableViewDelegate,UISearchResultsUpdating,UISearchBarDelegate>

@property(nonatomic,strong)UITableView * tableView;

@property(nonatomic,retain) UISearchController *searchController;
@property (strong, nonatomic) UILabel *  noDataLabel;

@property (strong, nonatomic) NSMutableArray *dataSource;/**<排序前的整个数据源*/
@property (strong, nonatomic) NSMutableArray *searchDataSource;/**<搜索结果数据源*/
@property (assign, nonatomic) BOOL  begainSearch;

@end

@implementation CityController
@synthesize cities, keys, delegate;

#pragma mark-----initTableView
- (void)createTable
{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 40;
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableView.sectionIndexColor = RGBCOLOR(57, 57, 57, 1);
    [self.view addSubview:self.tableView];
    
}

#pragma mark----- 获取数据源
- (void)getSourceData
{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"citydict"
                                                   ofType:@"plist"];
    self.cities = [[NSDictionary alloc]
                   initWithContentsOfFile:path];
    
    self.keys = [[cities allKeys] sortedArrayUsingSelector:
                 @selector(compare:)];
    

    _dataSource = [NSMutableArray array];
    NSArray *tempArray = [NSArray array];
    tempArray = [cities allValues];
    for (NSArray *cityArr in tempArray) {
        for (NSString *cityStr in cityArr) {
            [_dataSource addObject:cityStr];
        }
    }
    NSLog(@"数组中的所有城市:%@",_dataSource);
    
    _searchDataSource = [NSMutableArray new];

}


#pragma mark-----initUI
- (void)initUI{
    
    self.begainSearch = NO;
    
    //初始化搜索控制器
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.searchBar.showsCancelButton = YES;
    _searchController.searchBar.frame = CGRectMake(0, 64, Screen_Size.width-40, 44);
    //当搜索时隐藏导航栏
    _searchController.hidesNavigationBarDuringPresentation = NO;
    //设置代理为self
    _searchController.searchResultsUpdater = self;
    _searchController.searchBar.delegate = self;
    //是否在搜索时使背景变暗
    _searchController.dimsBackgroundDuringPresentation = NO;
    //使搜索条自适应当前视图的尺寸
    [_searchController.searchBar sizeToFit];
    _searchController.searchBar.tintColor = RGBCOLOR(52, 70, 136, 1);
    _searchController.searchBar.placeholder = @"搜索城市";
    
    
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationItem.titleView = _searchController.searchBar;
    
    for (UIView* subview in [[_searchController.searchBar.subviews lastObject] subviews]) {
        
        if ([subview isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField*)subview;
            //            textField.textColor = [UIColor redColor];                         //修改输入字体的颜色
            [textField setBackgroundColor:[UIColor groupTableViewBackgroundColor]];      //修改输入框的颜色
            //            [textField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];   //修改placeholder的颜色
        } else if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
        {
            [subview removeFromSuperview];
        }else if ([subview isKindOfClass:[UIButton class]]){

            UIButton *btn = (UIButton *)subview;
            [btn setTitle:@"取消" forState:UIControlStateNormal];
            btn.titleLabel.font = TextFontSize(16);
            [btn addTarget:self action:@selector(cancleBtn) forControlEvents:UIControlEventTouchUpInside];
            
        }
    }
    
    self.noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, Screen_Size.width, 40)];
    self.noDataLabel.textColor = [UIColor lightGrayColor];
    self.noDataLabel.font = TextFontSize(16);
    self.noDataLabel.text = @"没有搜索结果~";
    self.noDataLabel.textAlignment = NSTextAlignmentCenter;
    self.noDataLabel.hidden = YES;
  [self.tableView addSubview:self.noDataLabel];
    
}
- (void)cancleBtn
{
    NSLog(@"取消");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark-----tableViewdelegate datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.begainSearch) {
        
         return [keys count];
        
    }else{
        return 1;
    }
   
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
   
    if (!self.begainSearch) {
        
        NSString *key = [keys objectAtIndex:section];
        NSArray *citySection = [cities objectForKey:key];
        return [citySection count];
        
    }else{
        return _searchDataSource.count;
    }
    
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cityID = @"cityID";
    
    NSString *key = [keys objectAtIndex:indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cityID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cityID];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    
     if (!self.begainSearch) {
         
         cell.textLabel.text = [[self.cities objectForKey:key] objectAtIndex:indexPath.row];
     }else{
         cell.textLabel.text = _searchDataSource[indexPath.row];
     }
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
     if (!self.begainSearch) {
    NSString *key = [keys objectAtIndex:section];
    return key;
     }else{
         return nil;
     }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.begainSearch) {
        return 0.2;
    }
    return 30;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != NSNotFound) {
        if (!self.begainSearch) {
            NSString* key = [keys objectAtIndex:indexPath.section];
            [delegate getCityStr:[[cities objectForKey:key] objectAtIndex:indexPath.row]];
        }else{
            NSString* cityStr = _searchDataSource[indexPath.row];
            [delegate getCityStr:cityStr];
        }
    }
    self.searchController.active = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (!self.begainSearch) {
        return keys;
    }else{
        return nil;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (_begainSearch) {
        return 1.5;
    }
    return 0.0001;
}
#pragma mark -----UISearchResultsUpdating代理方法
//为搜索控件更新搜索结果，当搜索框的内容改变时执行
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    
    [_searchDataSource removeAllObjects];
    
    NSArray *ary = [NSArray new];
    ary = [ZYPinYinSearch searchWithOriginalArray:_dataSource andSearchText:searchController.searchBar.text andSearchByPropertyName:@""];
    
    if (searchController.searchBar.text.length == 0) {
        self.begainSearch = NO;
//        [_searchDataSource addObjectsFromArray:_dataSource];
    }else {
         self.begainSearch = YES;
        [_searchDataSource addObjectsFromArray:ary];
        _searchDataSource = [ChineseString SortArray:_searchDataSource];
    }
    [self.tableView reloadData];
    
#pragma mark-----没数据显示
    if (!self.begainSearch) {
        self.noDataLabel.hidden = YES;
    }else{
        if (_searchDataSource.count == 0) {
            self.noDataLabel.hidden = NO;
        }else{
            self.noDataLabel.hidden = YES;
        }
    }
}



#pragma mark-----生命周期
- (void)viewWillAppear:(BOOL)animated{
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createTable];
    [self initUI];
    [self getSourceData]; //获取所有城市数据源
  
}
- (void)viewWillDisappear:(BOOL)animated{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
