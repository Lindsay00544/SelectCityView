//
//  ViewController.m
//  SelectCityView
//
//  Created by 骆凡 on 2017/11/10.
//  Copyright © 2017年 user. All rights reserved.
//

#import "ViewController.h"
#import "CityController.h"

@interface ViewController ()<CityDelegate>
{
    UITextField *clickField;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"选择城市";
    
    clickField = [[UITextField alloc] initWithFrame:CGRectMake(100, 100, 100, 40)];
    clickField.placeholder = @"点击这里哦";
    [clickField addTarget:self action:@selector(changeText) forControlEvents:UIControlEventAllEvents];
    [self.view addSubview:clickField];

}

- (void)changeText{
    
    CityController *cityVC = [CityController new];
    cityVC.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cityVC];
    [self presentViewController:nav animated:YES completion:nil];
    
}

#pragma mark------getCityDelegate
- (void)getCityStr:(NSString *)cityStr{
    clickField.text = cityStr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
