//
//  MapViewController.m
//  Chat
//
//  Created by Bo Wang on 7/5/13.
//  Copyright (c) 2013 Bo Wang. All rights reserved.
//

#import "MapViewController.h"
#import "MyLocation.h"
#import <CoreLocation/CoreLocation.h>
#import "FieldStudyAppDelegate.h"
#define METERS_PER_MILE 1609.344
//#define DEVICE_SCHOOL
#define DEVICE_HOME

@interface MapViewController () {
    CLLocationManager *locationManager;
    NSMutableData *receivedData;
    NSMutableArray *locations;
    NSXMLParser *locationParser;
    
    NSString *name;
    NSString *latitude;
    NSString *longitude;
    Boolean inLatitude;
    Boolean inLongitude;
    
    UIButton *refreshButton;
}

@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    // Set a movement threshold for new events.
    locationManager.distanceFilter = 500;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.FieldMapView.userLocation.coordinate, 1*METERS_PER_MILE, 1*METERS_PER_MILE);
    
    [self.FieldMapView setRegion:viewRegion animated:YES];
    
    refreshButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [refreshButton addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchDown];
    [refreshButton setImage:[UIImage imageNamed:@"navigator.png"] forState:UIControlStateNormal];
    //refreshButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.FieldMapView addSubview:refreshButton];
    
}

-(void)viewWillLayoutSubviews {
    const CGRect viewBounds = self.view.bounds;
    const bool isPortrait = viewBounds.size.height >= viewBounds.size.width;
    if (isPortrait) {
        refreshButton.frame = CGRectMake(10, self.FieldMapView.bounds.size.height-45, 40,40);
    } else {
        refreshButton.frame = CGRectMake(10, self.FieldMapView.bounds.size.width-45, 40,40);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refresh{
    FieldStudyAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    if (delegate.userName != nil){
        
        [self updateUserLocation];
        [self getLocations];
    }
}

-(void)updateUserLocation{
    FieldStudyAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    if (delegate.userName != nil){
#ifdef SIMULATOR
    NSString *url = [NSString stringWithFormat:@"http://localhost:8888/ResearchProject/server-side/update-user-location.php?user=%@&latitude=%f&longitude=%f", delegate.userName, self.FieldMapView.u serLocation.coordinate.latitude, self.FieldMapView.userLocation.coordinate.longitude];
#endif
    
#ifdef DEVICE_SCHOOL
    NSString *url = [NSString stringWithFormat:@"http://172.29.0.199:8888/ResearchProject/server-side/update-user-location.php?user=%@&latitude=%f&longitude=%f", delegate.userName, self.FieldMapView.userLocation.coordinate.latitude, self.FieldMapView.userLocation.coordinate.longitude];
#endif
    
#ifdef DEVICE_HOME
        NSString *url = [NSString stringWithFormat:@"http://192.168.0.72:8888/ResearchProject/server-side/update-user-location.php?user=%@&latitude=%f&longitude=%f", delegate.userName, self.FieldMapView.userLocation.coordinate.latitude, self.FieldMapView.userLocation.coordinate.longitude];
#endif
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                        init];
        [request setURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"POST"];
        NSHTTPURLResponse *response = nil;
        NSError *error = [[NSError alloc] init];
        [NSURLConnection sendSynchronousRequest:request
                              returningResponse:&response error:&error];
    }
}

-(void)getLocations{
    FieldStudyAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
#ifdef SIMULATOR
    NSString *url = [NSString stringWithFormat:@"http://localhost:8888/ResearchProject/server-side/get-group-location.php?user=%@",delegate.userName];
#endif
    
#ifdef DEVICE_SCHOOL
    NSString *url = [NSString stringWithFormat:@"http://172.29.0.199:8888/ResearchProject/server-side/get-group-location.php?user=%@",delegate.userName];
#endif
    
#ifdef DEVICE_HOME
    NSString *url = [NSString stringWithFormat:@"http://192.168.0.72:8888/ResearchProject/server-side/get-group-location.php?user=%@",delegate.userName];
#endif
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn)
    {
        NSLog(@"connected");
        receivedData = [[NSMutableData alloc] init];
    }
    else
    {
        NSLog(@"not connected");
    }
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    if ( locations == nil )
        locations = [[NSMutableArray alloc] init];
    
    [locations removeAllObjects];
    
    locationParser = [[NSXMLParser alloc] initWithData:receivedData];
    [locationParser setDelegate:self];
    [locationParser parse];
    
    //To do: change annotation style
    //Remove all the previous annotations except for the user location annotation
    
    while ([self.FieldMapView.annotations count] > 1) {
        [self.FieldMapView removeAnnotation:[self.FieldMapView.annotations lastObject]];
    }
    
    NSLog(@"annotation count: %d",[self.FieldMapView.annotations count]);
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.FieldMapView.userLocation.coordinate, 1*METERS_PER_MILE, 1*METERS_PER_MILE);
    [self.FieldMapView setRegion:viewRegion animated:YES];
    
    for (id item in locations) {
        CLLocationCoordinate2D currLocation;
        currLocation.latitude = [[item objectForKey:@"latitude"] doubleValue];
        currLocation.longitude = [[item objectForKey:@"longitude"] doubleValue];
        NSString *currName = [item objectForKey:@"name"];
        MyLocation *annotation = [[MyLocation alloc] initWithName:currName coordinate:currLocation];
        [self.FieldMapView addAnnotation:annotation];
        
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict {
    if ( [elementName isEqualToString:@"user"] ) {
        name = [attributeDict objectForKey:@"name"];
        latitude = @"";
        longitude = @"";
        inLatitude = NO;
        inLongitude = NO;
    }
    if ( [elementName isEqualToString:@"latitude"] ) {
        inLatitude = YES;
    }
    if ( [elementName isEqualToString:@"longitude"] ) {
        inLongitude = YES;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ( inLatitude ) {
        latitude = string;
    }
    if ( inLongitude ) {
        longitude = string;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ( [elementName isEqualToString:@"user"] ) {
        [locations addObject:[NSDictionary dictionaryWithObjectsAndKeys:name,
                             @"name",latitude,@"latitude",longitude,@"longitude",nil]];
    }
    if ( [elementName isEqualToString:@"latitude"] ) {
        inLatitude = NO;
    }
    if ( [elementName isEqualToString:@"longitude"] ) {
        inLongitude = NO;
    }
}




@end
