//
//  AppDelegate.h
//  MapRoute
//
//  Created by Apple on 13-5-8.
//  Copyright (c) 2013年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    BMKMapManager *_mapManger;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@end
