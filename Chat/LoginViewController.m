//
//  LoginViewController.m
//  Chat
//
//  Created by Bo Wang on 7/7/13.
//  Copyright (c) 2013 Bo Wang. All rights reserved.
//

#import "LoginViewController.h"
#import "FieldStudyAppDelegate.h"

#define DEVICE_SCHOOL
//#define DEVICE_HOME

@interface LoginViewController () {
    UIAlertView *alert;
    
    NSString *user;
    NSString *password;
    NSURLConnection *conn;
    NSMutableData *receivedData;
    NSXMLParser *parser;
    
    Boolean inSuccess;
    Boolean inUser;
    NSString *userName;
    NSString *success;
}

@end

@implementation LoginViewController

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
    //[self login];
}

-(void)viewDidAppear:(BOOL)animated{
    [self login];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)login{
    alert = [[UIAlertView alloc] initWithTitle:@"Log In" message:@"" delegate:self cancelButtonTitle:@"Login" otherButtonTitles:@"Cancel", nil];
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        user = [[alertView textFieldAtIndex:0] text];
        password = [[alertView textFieldAtIndex:1] text];
        
        NSLog(@"Login:%@", user);
        NSLog(@"Password: %@", password);
        [self authenticate];
    } else {
        NSLog(@"Canceled!");
    }

}


- (void)authenticate {
#ifdef SIMULATOR
    NSString *url = [NSString stringWithFormat:
                     @"http://localhost:8888/ResearchProject/server-side/login.php?user=%@&passwor%@",user,password];
#endif
    //For device to access localhost
#ifdef DEVICE_SCHOOL
    NSString *url = [NSString stringWithFormat:
                     @"http://172.29.0.199:8888/ResearchProject/server-side/login.php?user=%@&password=%@",user,password];
#endif
    
#ifdef DEVICE_HOME
    NSString *url = [NSString stringWithFormat:
                     @"http://192.168.0.72:8888/ResearchProject/server-side/login.php?user=%@&password=%@",user,password];
#endif
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    
    conn =[[NSURLConnection alloc] initWithRequest:request delegate:self];
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
    if (connection == conn) {
        parser = [[NSXMLParser alloc] initWithData:receivedData];
        [parser setDelegate:self];
        [parser parse];
        
        if ([success isEqualToString:@"1"] ) {
            FieldStudyAppDelegate *delegate = (FieldStudyAppDelegate *)[[UIApplication sharedApplication] delegate];
            delegate.userName = userName;
        } else {
            [self shakeView:alert];
            FieldStudyAppDelegate *delegate = (FieldStudyAppDelegate *)[[UIApplication sharedApplication] delegate];
            delegate.userName = nil;
        }
    }
    
}

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict {
        if ( [elementName isEqualToString:@"login"] ) {
            userName = @"";
            success = @"";
            inUser = NO;
            inSuccess = NO;
        }
        if ( [elementName isEqualToString:@"success"] ) {
            inSuccess = YES;
        }
        if ( [elementName isEqualToString:@"user"] ) {
            inUser = YES;
        }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
        if ( inSuccess ) {
            success = [string stringByTrimmingCharactersInSet:
                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        if ( inUser ) {
            userName = [string stringByTrimmingCharactersInSet:
                        [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }

}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
        if ( [elementName isEqualToString:@"login"] ) {
            NSLog(@"user name is:%@",userName);
            NSLog(@"Is succeed:%@",success);
        }
        
        if ( [elementName isEqualToString:@"user"] ) {
            inUser = NO;
        }
        if ( [elementName isEqualToString:@"success"] ) {
            inSuccess = NO;
        }
}

#pragma mark - shake alertview

- (void)shakeView:(UIView *)viewToShake
{
    CGFloat t = 2.0;
    CGAffineTransform translateRight  = CGAffineTransformTranslate(CGAffineTransformIdentity, t, 0.0);
    CGAffineTransform translateLeft = CGAffineTransformTranslate(CGAffineTransformIdentity, -t, 0.0);
    
    viewToShake.transform = translateLeft;
    
    [UIView animateWithDuration:0.07 delay:0.0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
        [UIView setAnimationRepeatCount:2.0];
        viewToShake.transform = translateRight;
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                viewToShake.transform = CGAffineTransformIdentity;
            } completion:NULL];
        }
    }];
}

@end
