//
//  MapAnnotationView.h
//  FieldStdy
//
//  Created by Bo Wang on 7/21/13.
//  Copyright (c) 2013 Bo Wang. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MapAnnotationView : MKAnnotationView

@property (nonatomic,retain) MKMapView* mapView;

@end
