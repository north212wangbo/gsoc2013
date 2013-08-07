//
//  OrganizerTaskEditViewController.m
//  FieldStdy
//
//  Created by Bo Wang on 7/31/13.
//  Copyright (c) 2013 Bo Wang. All rights reserved.
//

#import "OrganizerTaskEditViewController.h"

//#define DEVICE_HOME
#define DEVICE_SCHOOL

@interface OrganizerTaskEditViewController () {
    NSMutableData *receivedData;
}

@end

@implementation OrganizerTaskEditViewController

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

    self.sampleTitle.text = self.sampleTitleText;
    self.amount.text = self.amountText;
    self.detail.text = self.detailText;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveEdit:(id)sender {
    self.saveButton.enabled = NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self updateTask];
}

#pragma mark - update task

- (void)updateTask {
    NSString *encodedDetail = [self.detail.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *encodedTitle = [self.sampleTitle.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
#ifdef DEVICE_SCHOOL
    NSString *url = [NSString stringWithFormat:@"http://172.29.0.199:8888/ResearchProject/server-side/update-sample.php?sampleId=%@&title=%@&amount=%@&detail=%@",self.sampleId,encodedTitle,self.amount.text,encodedDetail];
    NSLog(@"%@",url);
#endif

#ifdef DEVICE_HOME
    NSString *url = [NSString stringWithFormat:@"http://192.168.0.72:8888/ResearchProject/server-side/update-sample.php?sampleId=%@&title=%@&amount=%@&detail=%@",self.sampleId,encodedTitle,self.amount.text,encodedDetail];
#endif
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn)
    {
        NSLog(@"connected update-sample.php");
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
    NSLog(@"Update finished");
    self.saveButton.enabled = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
@end
