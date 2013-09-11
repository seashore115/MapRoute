//
//  ViewController.m
//  MapRoute
//
//  Created by Apple on 13-5-8.
//  Copyright (c) 2013年 Apple. All rights reserved.
//

#import "ViewController.h"
#define MYBUNDLE_NAME  @"mapapi.bundle"

#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: MYBUNDLE_NAME]

#define MYBUNDLE [NSBundle bundleWithPath: MYBUNDLE_PATH]

BOOL isRetina = FALSE;
@interface ViewController ()

@end

@interface RouteAnnotation : BMKPointAnnotation

{
    
    int _type; ///<0:起点 1：终点 2：公交 3：地铁 4:驾乘
    
    int _degree;
    
}

@property (nonatomic) int type;

@property (nonatomic) int degree;

@end

@implementation RouteAnnotation

@synthesize type = _type;

@synthesize degree = _degree;

@end

@interface UIImage(InternalMethod)

- (UIImage*)imageRotatedByDegrees:(CGFloat)degrees;

@end

@implementation UIImage(InternalMethod)

- (UIImage*)imageRotatedByDegrees:(CGFloat)degrees

{
    
    CGSize rotatedSize = self.size;
    
    if (isRetina) {
        
        rotatedSize.width *= 2;
        
        rotatedSize.height *= 2;
        
    }
    
    UIGraphicsBeginImageContext(rotatedSize);
    
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    CGContextRotateCTM(bitmap, degrees * M_PI / 180);
    
    CGContextRotateCTM(bitmap, M_PI);
    
    CGContextScaleCTM(bitmap, -1.0, 1.0);
    
    CGContextDrawImage(bitmap, CGRectMake(-rotatedSize.width/2, -rotatedSize.height/2, rotatedSize.width, rotatedSize.height), self.CGImage);
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 150, 320, 388)];
    
    [self.view addSubview:mapView];
//    _annotation = [[BMKPointAnnotation alloc]init];
//    _annotation.title = @"test";
//    _annotation.subtitle = @"this is a test!";
//    [mapView addAnnotation:_annotation];
    
    mapView.delegate = self;
    
    //[mapView setShowsUserLocation:YES];//显示定位
    
    _search = [[BMKSearch alloc]init];//search类，搜索的时候会用到
    
    _search.delegate = self;
    
    fromeText.text=@"新中关";
    toText.text=@"三里屯";
    
     BOOL flag = [_search geocode:fromeText.text withCity:cityStr];
    if (!flag) {
        
            NSLog(@"search failed234");
        
        }

    
    CGSize screenSize = [[UIScreen mainScreen] currentMode].size;
    
    if ((fabs(screenSize.width -640.0f) < 0.1)
        
        && (fabs(screenSize.height -960.0f) < 0.1))
        
    {
        
        isRetina = TRUE;
        
    }
    
    
    
    pathArray=[[NSMutableArray array] retain];  //用来记录路线信息的，以后会用到
	// Do any additional setup after loading the view, typically from a nib.
}


-(IBAction) showLocation:(id) sender {
    if ([[btnShowLocation titleForState:UIControlStateNormal]
         isEqualToString:@"显示位置"]) {
        [btnShowLocation setTitle:@"隐藏位置"
                         forState:UIControlStateNormal];
        mapView.showsUserLocation = YES;
    } else {
        [btnShowLocation setTitle:@"显示位置"
                         forState:UIControlStateNormal];
        mapView.showsUserLocation = NO;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)mapView:(BMKMapView *)mapView1 didUpdateUserLocation:(BMKUserLocation *)userLocation{
    
    NSLog(@"!latitude!!!  %f",userLocation.location.coordinate.latitude);//获取经度
    
    NSLog(@"!longtitude!!!  %f",userLocation.location.coordinate.longitude);//获取纬度
    
    localLatitude=userLocation.location.coordinate.latitude;//把获取的地理信息记录下来
    
    localLongitude=userLocation.location.coordinate.longitude;
    
    if (userLocation != nil) {
		NSLog(@"%f %f", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
        
        //将地图移动到当前位置
        float zoomLevel = 0.02;
        BMKCoordinateRegion region = BMKCoordinateRegionMake(userLocation.location.coordinate,BMKCoordinateSpanMake(zoomLevel, zoomLevel));
        [mapView setRegion:[mapView regionThatFits:region] animated:YES];
        
        //大头针摆放的坐标，必须从这里进行赋值，否则取不到值 ，这里可能涉及到委托方法执行顺序的问题
//        CLLocationCoordinate2D coor;
//        coor.latitude = userLocation.location.coordinate.latitude;
//        coor.longitude = userLocation.location.coordinate.longitude;
//        _annotation.coordinate = coor;
	}

    
    CLGeocoder *Geocoder=[[CLGeocoder alloc]init];
    
    CLGeocodeCompletionHandler handler = ^(NSArray *place, NSError *error) {
        
        for (CLPlacemark *placemark in place) {
            
            cityStr=placemark.thoroughfare;
            
            cityName=placemark.locality;
            
            NSLog(@"city %@",cityStr);//获取街道地址
            
            NSLog(@"cityName %@",cityName);//获取城市名
            
            break;
            
        }
        
    };
    
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:userLocation.location.coordinate.latitude longitude:userLocation.location.coordinate.longitude];
    
    [Geocoder reverseGeocodeLocation:loc completionHandler:handler];
    
}


- (void)onGetAddrResult:(BMKAddrInfo*)result errorCode:(int)error{
    
    NSLog(@"11111   %f" ,result.geoPt.latitude);//获得地理名“新中关”的纬度
    
    NSLog(@"22222   %f" ,result.geoPt.longitude);//获得地理名“心中关”的经度
    
    NSLog(@"33333 %@",result.strAddr);//街道名
    
    NSLog(@"4444 %@",result.addressComponent.province);//所在省份
    
    NSLog(@"555 %@" ,result.addressComponent.city);
    
    startPt = (CLLocationCoordinate2D){0, 0};
    
    startPt = result.geoPt;//把坐标传给startPt保存起来
    
}


-(IBAction)hiddenButton:(id)sender{
    [fromeText resignFirstResponder];
    [toText resignFirstResponder];
}


-(IBAction)onClickDriveSearch

{
    
    //清除之前的路线和标记
    
    NSArray* array = [NSArray arrayWithArray:mapView.annotations];
    
    [mapView removeAnnotations:array];
    
    array = [NSArray arrayWithArray:mapView.overlays];
    
    [mapView removeOverlays:array];
    
    //清楚路线方案的提示信息
    
    [pathArray removeAllObjects];
    
    //如果是从当前位置为起始点
    
    if (localJudge) {
        
        BMKPlanNode* start = [[BMKPlanNode alloc]init];
        
        startPt.latitude=localLatitude;
        
        startPt.longitude=localLongitude;
        
        start.pt = startPt;
        
        start.name = cityStr;
        
        BMKPlanNode* end = [[BMKPlanNode alloc]init];
        
        end.name = toText.text;
        
        BOOL flag1 = [_search drivingSearch:cityName startNode:start endCity:@"北京市" endNode:end];
        
        if (!flag1) {
            
            NSLog(@"search failed123");
            
        }
        
        [start release];
        
        [end release];
        
    }else {
        
        //如果从textfield获取起始点，不定位的话主要看这里
        
        //BOOL flag = [_search geocode:fromeText.text withCity:cityStr];//通过搜索textfield地名获得地名的经纬度，之前已经讲过了，并存储在变量startPt里
        
        //if (!flag) {
            
        //    NSLog(@"search failed234");
            
        //}
        
        BMKPlanNode* start = [[BMKPlanNode alloc]init];
        
        start.pt = startPt;//起始点坐标
        
        start.name = fromeText.text;//起始点名字
        
        BMKPlanNode* end = [[BMKPlanNode alloc]init];
        
        end.name = toText.text;//结束点名字
        
        BOOL flag1 = [_search drivingSearch:cityName startNode:start endCity:@"北京市" endNode:end];//这个就是驾车路线查询函数，利用了startPt存储的起始点坐标，会调用代理方法onGetDrivingRouteResult
        
        if (!flag1) {
            
            NSLog(@"search failed345");
            
        }
        
        [start release];
        
        [end release];
        
    }
    
}

-(IBAction)onClickBusSearch

{
    
    
    
    //清空路线
    
    NSArray* array = [NSArray arrayWithArray:mapView.annotations];
    
    [mapView removeAnnotations:array];
    
    array = [NSArray arrayWithArray:mapView.overlays];
    
    [mapView removeOverlays:array];
    
    
    
    [pathArray removeAllObjects];
    
    if (localJudge) {
        
        //开始搜索路线，transitSearch调用onGetTransitRouteResult
        
        BMKPlanNode* start = [[BMKPlanNode alloc]init];
        
        startPt.latitude=localLatitude;
        
        startPt.longitude=localLongitude;
        
        start.pt = startPt;
        
        start.name = cityStr;
        
        BMKPlanNode* end = [[BMKPlanNode alloc]init];
        
        end.name = toText.text;
        
        BOOL flag1 = [_search transitSearch:@"北京市" startNode:start endNode:end];
        
        if (!flag1) {
            
            NSLog(@"search failed1");
            
        }
        
        [start release];
        
        [end release];
        
    }else{
        
        //由textfield内容搜索，调用onGetAddrResult函数，得到目标点坐标startPt
        //
        //        BOOL flag = [_search geocode:fromeText.text withCity:cityStr];
        //
        //        if (!flag) {
        //
        //            NSLog(@"search failed2");
        
        //        }
        
        //开始搜索路线，transitSearch调用onGetTransitRouteResult
        
        BMKPlanNode* start = [[BMKPlanNode alloc]init];
        
        start.pt = startPt;
        
        start.name = fromeText.text;
        
        BMKPlanNode* end = [[BMKPlanNode alloc]init];
        
        
        end.name = toText.text;
        
        BOOL flag1 = [_search transitSearch:@"北京市" startNode:start endNode:end];//公交路线对应的代理方法是onGetTransitRouteResult
        
        if (!flag1) {
            
            NSLog(@"search failed3");
            
        }
        
        [start release];
        
        [end release];
        
        
        
    }
    
}


- (void)onGetDrivingRouteResult:(BMKPlanResult*)result errorCode:(int)error

{
    
    NSLog(@"onGetDrivingRouteResult:error:%d", error);
    
    if (error == BMKErrorOk) {
        
        BMKRoutePlan* plan = (BMKRoutePlan*)[result.plans objectAtIndex:0];
        
        RouteAnnotation* item = [[RouteAnnotation alloc]init];
        
        item.coordinate = result.startNode.pt;
        
        item.title = @"起点";
        
        item.type = 0;
        
        [mapView addAnnotation:item];
        
        [item release];
        
        int index = 0;
        
        int size = [plan.routes count];
        
        for (int i = 0; i < 1; i++) {
            
            BMKRoute* route = [plan.routes objectAtIndex:i];
            
            for (int j = 0; j < route.pointsCount; j++) {
                
                int len = [route getPointsNum:j];
                
                index += len;
                
            }
            
        }
        
        BMKMapPoint* points = new BMKMapPoint[index];
        
        index = 0;
        
        for (int i = 0; i < 1; i++) {
            
            BMKRoute* route = [plan.routes objectAtIndex:i];
            
            for (int j = 0; j < route.pointsCount; j++) {
                
                int len = [route getPointsNum:j];
                
                BMKMapPoint* pointArray = (BMKMapPoint*)[route getPoints:j];
                
                memcpy(points + index, pointArray, len * sizeof(BMKMapPoint));
                
                index += len;
                
            }
            
            size = route.steps.count;
            
            for (int j = 0; j < size; j++) {
                
                BMKStep* step = [route.steps objectAtIndex:j];
                
                item = [[RouteAnnotation alloc]init];
                
                item.coordinate = step.pt;
                
                item.title = step.content;
                
                item.degree = step.degree * 30;
                
                item.type = 4;
                
                [mapView addAnnotation:item];
                
                [item release];
                
                //把每一个步骤的提示信息存储到pathArray里，以后可以用这个内容实现文字导航
                
                [pathArray addObject:step.content];
                
            }
            
            
            
        }
        
        
        
        item = [[RouteAnnotation alloc]init];
        
        item.coordinate = result.endNode.pt;
        
        item.type = 1;
        
        item.title = @"终点";
        
        [mapView addAnnotation:item];
        
        [item release];
        
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:points count:index];
        
        [mapView addOverlay:polyLine];
        
        delete []points;
        
        //打印pathArray，检验获取的文字导航提示信息
        
        for (NSString *string in pathArray) {
            
            NSLog(@"patharray2 %@",string);
            
        }
        
    }
    
    
    
}

-(IBAction)onClickSelfPosition{
    localJudge=YES;
}



- (void)onGetTransitRouteResult:(BMKPlanResult*)result errorCode:(int)error

{
    
    NSLog(@"onGetTransitRouteResult:error:%d", error);
    
    if (error == BMKErrorOk) {
        
        BMKTransitRoutePlan* plan = (BMKTransitRoutePlan*)[result.plans objectAtIndex:0];
        
        
        
        RouteAnnotation* item = [[RouteAnnotation alloc]init];
        
        item.coordinate = plan.startPt;
        
        item.title = @"起点";
        
        item.type = 0;
        
        [mapView addAnnotation:item];
        
        [item release];
        
        item = [[RouteAnnotation alloc]init];
        
        item.coordinate = plan.endPt;
        
        item.type = 1;
        
        item.title = @"终点";
        
        [mapView addAnnotation:item];
        
        [item release];
        
        
        
        int size = [plan.lines count];
        
        int index = 0;
        
        for (int i = 0; i < size; i++) {
            
            BMKRoute* route = [plan.routes objectAtIndex:i];
            
            for (int j = 0; j < route.pointsCount; j++) {
                
                int len = [route getPointsNum:j];
                
                index += len;
                
            }
            
            BMKLine* line = [plan.lines objectAtIndex:i];
            
            index += line.pointsCount;
            
            if (i == size - 1) {
                
                i++;
                
                route = [plan.routes objectAtIndex:i];
                
                for (int j = 0; j < route.pointsCount; j++) {
                    
                    int len = [route getPointsNum:j];
                    
                    index += len;
                    
                }
                
                break;
                
            }
            
        }
        
        
        
        BMKMapPoint* points = new BMKMapPoint[index];
        
        index = 0;
        
        
        
        for (int i = 0; i < size; i++) {
            
            BMKRoute* route = [plan.routes objectAtIndex:i];
            
            for (int j = 0; j < route.pointsCount; j++) {
                
                int len = [route getPointsNum:j];
                
                BMKMapPoint* pointArray = (BMKMapPoint*)[route getPoints:j];
                
                memcpy(points + index, pointArray, len * sizeof(BMKMapPoint));
                
                index += len;
                
            }
            
            BMKLine* line = [plan.lines objectAtIndex:i];
            
            memcpy(points + index, line.points, line.pointsCount * sizeof(BMKMapPoint));
            
            index += line.pointsCount;
            
            
            
            item = [[RouteAnnotation alloc]init];
            
            item.coordinate = line.getOnStopPoiInfo.pt;
            
            item.title = line.tip;
            
            // NSLog(@”2222  %@”,line.tip);//上车信息，和下车信息加入数组的速度会配合，按顺序加入，不用考虑顺序问题
            
            [pathArray addObject:line.tip];
            
            if (line.type == 0) {
                
                item.type = 2;
                
            } else {
                
                item.type = 3;
                
            }
            
            
            
            [mapView addAnnotation:item];
            
            [item release];
            
            route = [plan.routes objectAtIndex:i+1];
            
            item = [[RouteAnnotation alloc]init];
            
            item.coordinate = line.getOffStopPoiInfo.pt;
            
            item.title = route.tip;
            
            // NSLog(@”2222  %@”,line.tip);
            
            // NSLog(@”3333  %@”,item.title);//下车信息
            
            [pathArray addObject:item.title];
            
            if (line.type == 0) {
                
                item.type = 2;
                
            } else {
                
                item.type = 3;
                
            }
            
            [mapView addAnnotation:item];
            
            [item release];
            
            if (i == size - 1) {
                
                i++;
                
                route = [plan.routes objectAtIndex:i];
                
                for (int j = 0; j < route.pointsCount; j++) {
                    
                    int len = [route getPointsNum:j];
                    
                    BMKMapPoint* pointArray = (BMKMapPoint*)[route getPoints:j];
                    
                    memcpy(points + index, pointArray, len * sizeof(BMKMapPoint));
                    
                    index += len;
                    
                }
                
                break;
                
            }
            
        }
        
        
        
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:points count:index];
        
        [mapView addOverlay:polyLine];
        
        delete []points;
        
        for (NSString *string in pathArray) {
            
            NSLog(@"bus %@",string);
            
        }
        
    }
    
}




- (NSString*)getMyBundlePath1:(NSString *)filename

{
    
    NSBundle * libBundle = MYBUNDLE ;
    
    if ( libBundle && filename ){
        
        NSString * s=[[libBundle resourcePath ] stringByAppendingPathComponent : filename];
        
        NSLog ( @"%@" ,s);
        
        return s;
        
    }
    
    return nil ;
    
}


//选择交通方式
- (BMKAnnotationView*)getRouteAnnotationView:(BMKMapView *)mapview viewForAnnotation:(RouteAnnotation*)routeAnnotation
{
	BMKAnnotationView* view = nil;
	switch (routeAnnotation.type) {
		case 0:
		{
			view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"start_node"];
			if (view == nil) {
				view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"start_node"];
				view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_start.png"]];
				view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
				view.canShowCallout = TRUE;
			}
			view.annotation = routeAnnotation;
		}
			break;
		case 1:
		{
			view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"end_node"];
			if (view == nil) {
				view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"end_node"];
				view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_end.png"]];
				view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
				view.canShowCallout = TRUE;
			}
			view.annotation = routeAnnotation;
		}
			break;
		case 2:
		{
			view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"bus_node"];
			if (view == nil) {
				view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"bus_node"];
				view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_bus.png"]];
				view.canShowCallout = TRUE;
			}
			view.annotation = routeAnnotation;
		}
			break;
		case 3:
		{
			view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"rail_node"];
			if (view == nil) {
				view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"rail_node"];
				view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_rail.png"]];
				view.canShowCallout = TRUE;
			}
			view.annotation = routeAnnotation;
		}
			break;
		case 4:
		{
			view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"route_node"];
			if (view == nil) {
				view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"route_node"];
				view.canShowCallout = TRUE;
			} else {
				[view setNeedsDisplay];
			}
			
			UIImage* image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_direction.png"]];
			view.image = [image imageRotatedByDegrees:routeAnnotation.degree];
			view.annotation = routeAnnotation;
			
		}
			break;
		default:
			break;
	}
	
	return view;
}
//标记
- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation
{
	if ([annotation isKindOfClass:[RouteAnnotation class]]) {
		return [self getRouteAnnotationView:view viewForAnnotation:(RouteAnnotation*)annotation];
	}
	return nil;
}

//涂层覆盖
- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay
{
	if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[[BMKPolylineView alloc] initWithOverlay:overlay] autorelease];
        polylineView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:1];
        polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        polylineView.lineWidth = 3.0;
        return polylineView;
    }
	return nil;
}


- (void)viewWillAppear:(BOOL)animated
{
    mapView.delegate = self;
    _search.delegate = self;
}


//weibo分享触发
- (IBAction)sendtoWeibo:(id)sender {
    
    if ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue]>=6) {
        
        
        // if([SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo])
        //{
        slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
        [slComposerSheet setInitialText:@"#MapRoute#"];
        [slComposerSheet addImage:[UIImage imageNamed:@"ios6.jpg"]];
        [slComposerSheet addURL:[NSURL URLWithString:@"http://www.weibo.com/"]];
        [self presentViewController:slComposerSheet animated:YES completion:nil];
        //}
        [slComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            NSLog(@"start completion block");
            NSString *output;
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    output = @"Action Cancelled";
                    break;
                case SLComposeViewControllerResultDone:
                    output = @"Post Successfull";
                    break;
                default:
                    break;
            }
            if (result != SLComposeViewControllerResultCancelled)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Weibo Message" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
        }];
        
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://weibo.com"]];
        
    }
    
    
}



@end
