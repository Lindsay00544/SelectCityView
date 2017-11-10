//
//  CityController.h
//  BianLi
//
//  Created by 骆凡 on 16/6/23.
//  Copyright © 2016年 user. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CityDelegate.h"

@interface CityController : UIViewController
{
    NSDictionary * cities;
    NSArray      * keys;
}
@property (nonatomic, retain) NSDictionary *cities;

@property (nonatomic, retain) NSArray *keys; 

@property (nonatomic, assign) id <CityDelegate> delegate;

@end

@protocol CityListViewControllerProtocol

- (void) citySelectionUpdate:(NSString*)selectedCity;

- (NSString*) getDefaultCity;
@end
