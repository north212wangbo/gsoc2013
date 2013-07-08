//
//  MapViewController.h
//  Chat
//
//  Created by Bo Wang on 7/5/13.
//  Copyright (c) 2013 Bo Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController <NSXMLParserDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *FieldMapView;

@end
