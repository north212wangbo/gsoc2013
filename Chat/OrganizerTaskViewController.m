//
//  OrganizerTaskViewController.m
//  FieldStdy
//
//  Created by Bo Wang on 7/31/13.
//  Copyright (c) 2013 Bo Wang. All rights reserved.
//

#import "OrganizerTaskViewController.h"
#import "OrganizerTaskDetailViewController.h"
//#define DEVICE_HOME
#define DEVICE_SCHOOL


@interface OrganizerTaskViewController () {
    NSMutableArray *studentList;
    NSMutableData *receivedData;
    Boolean inName;
    NSString *studentName;
}

@end

@implementation OrganizerTaskViewController

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
    //This require view to be loaded first, should find better way
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getStudentList) name:@"loginSucceed" object:nil];    
	// Do any additional setup after loading the view.
    [self getStudentList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getStudentList {
#ifdef SIMULATOR
    NSString *url = @"http://localhost:8888/ResearchProject/server-side/student-list.php";
#endif
    
#ifdef DEVICE_SCHOOL
    NSString *url = @"http://69.166.62.3/~bowang/gsoc/student-list.php";
#endif
    
#ifdef DEVICE_HOME
    NSString *url = @"http://192.168.0.72:8888/ResearchProject/server-side/student-list.php";
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
    if ( studentList == nil )
        studentList = [[NSMutableArray alloc] init];
    
    [studentList removeAllObjects];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:receivedData];
    [parser setDelegate:self];
    [parser parse];
    [self.tableView reloadData];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.refreshButton.enabled = YES;
}

#pragma mark - XML Parser

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict {
        if ([elementName isEqualToString:@"name"]) {
            inName = YES;
        }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
        if (inName) {
            studentName = string;
        }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
        if ( [elementName isEqualToString:@"student"] ) {
            [studentList addObject:[NSDictionary dictionaryWithObjectsAndKeys:studentName,
                               @"name",nil]];
        }
        
        if ( [elementName isEqualToString:@"name"] ) {
            inName = NO;
        }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (studentList == nil)?0:[studentList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:
(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"studentList";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    // Configure the cell...
        
    NSDictionary *itemAtIndex = (NSDictionary *)[studentList objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat: @"%@",[itemAtIndex objectForKey:@"name"]];
    cell.textLabel.font = [UIFont systemFontOfSize:17];

    
    return cell;
}
- (IBAction)refresh:(id)sender {
    self.refreshButton.enabled = NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self getStudentList];
}

#pragma mark - Table view delegate and segue

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
    //TaskDetailViewController *detailViewController = [[TaskDetailViewController alloc] init];
    // ...
    // Pass the selected object to the new view controller.
    //[self.navigationController pushViewController:detailViewController animated:YES];
    //[self performSegueWithIdentifier:@"OrganizerTaskDetailViewSegue" sender:self];    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if ([segue.identifier isEqualToString:@"OrganizerTaskDetailViewSegue"]) {
        OrganizerTaskDetailViewController *controller = segue.destinationViewController;
        NSDictionary *itemAtIndex = (NSDictionary *)[studentList objectAtIndex:indexPath.row];
        controller.user = [itemAtIndex objectForKey:@"name"];
        controller.hidesBottomBarWhenPushed = YES;
    }
}
@end
