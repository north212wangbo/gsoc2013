//
//  AddNewSampleViewController.m
//  FieldStdyForOrganizer
//
//  Created by Bo Wang on 8/4/13.
//  Copyright (c) 2013 Bo Wang. All rights reserved.
//

#import "AddNewSampleViewController.h"

//#define DEVICE_HOME
#define DEVICE_SCHOOL

@interface AddNewSampleViewController () {
    NSMutableData *receivedData;
}

@end

@implementation AddNewSampleViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveNewSample:(id)sender {
    self.saveButton.enabled = NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self addNewSample];
    
}

- (void)addNewSample{
    NSString *encodedDetail = [self.detail.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *encodedTitle = [self.sampleTitle.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *encodedAmount = [self.amount.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
#ifdef DEVICE_SCHOOL
    NSString *url = [NSString stringWithFormat:@"http://172.29.0.199:8888/ResearchProject/server-side/add-newSample.php?title=%@&amount=%@&detail=%@",encodedTitle,encodedAmount,encodedDetail];
#endif
    
#ifdef DEVICE_HOME
    NSString *url = [NSString stringWithFormat:@"http://192.168.0.72:8888/ResearchProject/server-side/add-newSample.php?title=%@&amount=%@&detail=%@",encodedTitle,encodedAmount,encodedDetail];
#endif
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn)
    {
        NSLog(@"connected add-newSample.php");
        receivedData = [[NSMutableData alloc] init];
    }
    else
    {
        NSLog(@"not connected");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Insert finished");
    self.saveButton.enabled = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.navigationController popViewControllerAnimated:YES];
}
@end
