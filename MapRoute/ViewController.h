//
//  ViewController.h
//  MapRoute
//
//  Created by Apple on 13-5-8.
//  Copyright (c) 2013年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface ViewController : UIViewController<BMKMapViewDelegate,BMKSearchDelegate>{
    BMKSearch* _search;//搜索要用到的
    
    BMKMapView* mapView;//地图视图
    
    BMKPointAnnotation *_annotation;
    
    IBOutlet UITextField* fromeText;
    IBOutlet UITextField * toText;
    
    NSString  *cityStr;
    
    NSString *cityName;
    
    CLLocationCoordinate2D startPt;
    
    float localLatitude;
    
    float localLongitude;
    
    BOOL localJudge;
    
    NSMutableArray *pathArray;
    SLComposeViewController *slComposerSheet;
    
    IBOutlet UIButton *btnShowLocation;
}

-(IBAction)sendtoWeibo:(id)sender;
-(IBAction)onClickDriveSearch;
-(IBAction)onClickBusSearch;
-(IBAction)onClickSelfPosition;
-(IBAction)hiddenButton:(id)sender;
-(IBAction)showLocation:(id)sender;
@end
