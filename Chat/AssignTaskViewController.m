//
//  AssignTaskViewController.m
//  FieldStdyForOrganizer
//
//  Created by Bo Wang on 8/4/13.
//  Copyright (c) 2013 Bo Wang. All rights reserved.
//

#import "AssignTaskViewController.h"
#import "FieldStudyAppDelegate.h"

#define DEVICE_SCHOOL
//#define DEVICE_HOME

@interface AssignTaskViewController () {
    NSURLConnection *conn, *conn2;
    NSMutableData *receivedData;
    NSMutableArray *samples;
    NSMutableArray *samplesChecked;
    
    NSString *sampleId;
    NSString *studentId;
    NSString *sampleName;
    
    Boolean inName,inAssignedTo;
    NSDictionary *taskInfo;
}

@end

@implementation AssignTaskViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    samplesChecked = [[NSMutableArray alloc] init];

    UIBarButtonItem *newSampleButton = [[UIBarButtonItem alloc] initWithTitle:@"New Sample" style:UIBarButtonItemStylePlain target:self action:@selector(addTask)];
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(submit)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:submitButton,newSampleButton, nil];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(getSampleList) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    [self getSampleList];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)submit {
    FieldStudyAppDelegate *delegate = (FieldStudyAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    for (int i=0; i<[samples count];i++) {
        if ([[samplesChecked objectAtIndex:i] boolValue]==YES) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            
            NSDictionary *itemAtIndex = [samples objectAtIndex:i];
            NSString *saID = [itemAtIndex objectForKey:@"id"];
#ifdef DEVICE_SCHOOL
            NSString *url = [NSString stringWithFormat:@"http://172.29.0.199:8888/ResearchProject/server-side/assign-newtask.php?oID=%@&studentID=%@&saID=%@",delegate.userName,self.studentId,saID];
#endif
            
#ifdef DEVICE_HOME
            NSString *url =[NSString stringWithFormat:@"http://192.168.0.72:8888/ResearchProject/server-side/assign-newtask.php?oID=%@&studentID=%@&saID=%@",delegate.userName,self.studentId,saID];
#endif
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:url]];
            [request setHTTPMethod:@"GET"];
            
            
            conn2 =[[NSURLConnection alloc] initWithRequest:request delegate:self];
            if (conn2)
            {
                NSLog(@"assgin new task connected");
                receivedData = [[NSMutableData alloc] init];
            }
            else
            {
                NSLog(@"not connected");
            }
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addTask {
    [self performSegueWithIdentifier:@"addNewSampleSegue" sender:self];
}

- (void)getSampleList {
#ifdef DEVICE_SCHOOL
    NSString *url = @"http://172.29.0.199:8888/ResearchProject/server-side/get-sampleList.php";
    
#endif
    
#ifdef DEVICE_HOME
    NSString *url = @"http://192.168.0.72:8888/ResearchProject/server-side/get-sampleList.php";
#endif
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
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
    if (connection == conn) {
        if ( samples == nil )
            samples = [[NSMutableArray alloc] init];
        
        [samples removeAllObjects];
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:receivedData];
        [parser setDelegate:self];
        [parser parse];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
        
        for (int i=0; i<[samples count]; i++) {
            [samplesChecked insertObject:@"False" atIndex:i];
        }
        
    } else if (connection == conn2) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    
}

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"sample"]) {
        sampleId = [attributeDict objectForKey:@"id"];
        inName = NO;
        inAssignedTo = NO;
    }
    if ([elementName isEqualToString:@"name"]) {
        inName = YES;
    }
    if ([elementName isEqualToString:@"AssignedTo"]) {
        inAssignedTo = YES;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ( inName ) {
        sampleName = string;
    }
    if ( inAssignedTo ) {
        studentId = string;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ( [elementName isEqualToString:@"sample"] ) {
        taskInfo = [NSDictionary dictionaryWithObjectsAndKeys:sampleName, @"name",sampleId,@"id",studentId,@"AssignedTo",nil];
        [samples addObject:taskInfo];
        studentId = @"";
    }
    
    if ( [elementName isEqualToString:@"name"] ) {
        inName = NO;
    }
    if ( [elementName isEqualToString:@"AssignedTo"] ) {
        inAssignedTo = NO;
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (samples == nil)? 0:[samples count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"sampleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *itemAtIndex = (NSDictionary *)[samples objectAtIndex:indexPath.row];
    cell.textLabel.text = [itemAtIndex objectForKey:@"name"];
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    cell.detailTextLabel.numberOfLines = 0;
    if (![[itemAtIndex objectForKey:@"AssignedTo"] isEqualToString:@""]) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Assigned to %@",[itemAtIndex objectForKey:@"AssignedTo"]];
    } else {
        cell.detailTextLabel.text = @"Not assigned";
        
        UIImage *image = [UIImage imageNamed:@"unchecked.png"];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
        button.frame = frame;
        button.tag = indexPath.row;
        [button setBackgroundImage:image forState:UIControlStateNormal];
        
        [button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = button;
    }
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    
    return cell;
}

-(void)checkButtonTapped:(id)sender event:(UIEvent *)event{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath!=nil) {
        [self tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    BOOL checked = [[samplesChecked objectAtIndex:indexPath.row] boolValue];
    [samplesChecked removeObjectAtIndex:indexPath.row];
    [samplesChecked insertObject:checked?@"FALSE":@"TRUE" atIndex:indexPath.row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIButton *button = (UIButton *)cell.accessoryView;
    
    UIImage *newImage = (checked)? [UIImage imageNamed:@"unchecked.png"]:[UIImage imageNamed:@"checked.png"];
    [button setBackgroundImage:newImage forState:UIControlStateNormal];
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
