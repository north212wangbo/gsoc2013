//
//  TasksViewController.m
//  FieldStdy
//
//  Created by Bo Wang on 7/10/13.
//  Copyright (c) 2013 Bo Wang. All rights reserved.
//

#import "TasksViewController.h"
#import "FieldStudyAppDelegate.h"
#import "TaskDetailViewController.h"
#define DEVICE_SCHOOL
//#define DEVICE_HOME


//To do: pull down to refresh
@interface TasksViewController () {
    NSMutableArray *tasks;
    NSMutableArray *tasksFinished;
    
    NSString *user;
    NSMutableData *receivedData;
    NSXMLParser *parser;
    NSURLConnection *conn1,*conn2;
    
    Boolean inName;
    Boolean inAmount;
    Boolean inDesc;
    Boolean inCompleted;
    NSString *sampleName;
    NSString *amount;
    NSString *desc;
    NSString *sampleId;
    NSString *completed;
    NSDictionary *taskInfo;
}

@end

@implementation TasksViewController

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
    tasksFinished = [[NSMutableArray alloc] init];
    // Uncomment the following line to preserve selection between presentations.
    //self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
     self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(getTaskList) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    [self getTaskList];
}

-(void)viewDidAppear:(BOOL)animated{
    [self getTaskList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (tasks == nil)? 0:[tasks count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:
(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"taskIdentifier"];
    //cell = (UITableViewCell *)[self.messageList dequeueReusableCellWithIdentifier:@"ChatListItem"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"taskIdentifier"
                                                     owner:self options:nil];
        cell = (UITableViewCell *)[nib objectAtIndex:0];
    }
    
    NSDictionary *itemAtIndex = (NSDictionary *)[tasks objectAtIndex:indexPath.row];
    cell.textLabel.text = [itemAtIndex objectForKey:@"name"];
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.text = [itemAtIndex objectForKey:@"desc"];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    
    BOOL checked = [[itemAtIndex objectForKey:@"completed"] boolValue];
    UIImage *image = (checked)? [UIImage imageNamed:@"checked.png"]:[UIImage imageNamed:@"unchecked.png"];
    if (checked) {
        [tasksFinished insertObject:@"True" atIndex:indexPath.row];
    } else {
        [tasksFinished insertObject:@"False" atIndex:indexPath.row];
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    button.frame = frame;
    button.tag = indexPath.row;
    [button setBackgroundImage:image forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = button;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    BOOL checked = [[tasksFinished objectAtIndex:indexPath.row] boolValue];
    [tasksFinished removeObjectAtIndex:indexPath.row];
    [tasksFinished insertObject:checked?@"FALSE":@"TRUE" atIndex:indexPath.row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIButton *button = (UIButton *)cell.accessoryView;
    
    UIImage *newImage = (checked)? [UIImage imageNamed:@"unchecked.png"]:[UIImage imageNamed:@"checked.png"];
    [button setBackgroundImage:newImage forState:UIControlStateNormal];
    
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

#pragma mark - Table view delegate and segue

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
     //TaskDetailViewController *detailViewController = [[TaskDetailViewController alloc] init];
     // ...
     // Pass the selected object to the new view controller.
     //[self.navigationController pushViewController:detailViewController animated:YES];
    [self performSegueWithIdentifier:@"TaskDetailViewSegue" sender:self];
     
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if ([segue.identifier isEqualToString:@"TaskDetailViewSegue"]) {
        TaskDetailViewController *controller = segue.destinationViewController;
        NSDictionary *itemAtIndex = (NSDictionary *)[tasks objectAtIndex:indexPath.row];
        controller.taskId = [itemAtIndex objectForKey:@"id"];
        controller.hidesBottomBarWhenPushed = YES;
    }
}

#pragma mark - get task list

-(void)getTaskList{
    FieldStudyAppDelegate *delegate = (FieldStudyAppDelegate *)[[UIApplication sharedApplication] delegate];
#ifdef DEVICE_SCHOOL
    NSString *url = [NSString stringWithFormat:@"http://172.29.0.199:8888/ResearchProject/server-side/get-student-tasks.php?user=%@",delegate.userName];
    
#endif
    
#ifdef DEVICE_HOME
    NSString *url = [NSString stringWithFormat:@"http://192.168.0.72:8888/ResearchProject/server-side/get-student-tasks.php?user=%@",delegate.userName];
#endif
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    conn1=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn1)
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
    if (connection == conn1) {
        if ( tasks == nil )
            tasks = [[NSMutableArray alloc] init];
        
        [tasks removeAllObjects];  //remove the record of previous user, should find better way
        parser = [[NSXMLParser alloc] initWithData:receivedData];
        [parser setDelegate:self];
        [parser parse];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    } else if (connection == conn2) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        self.submitButton.enabled = YES;
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:user,@"user",nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"taskUpdate" object:self userInfo:dict];
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
        inAmount = NO;
        inDesc =NO;
    }
    if ([elementName isEqualToString:@"name"]) {
        inName = YES;
    }
    if ([elementName isEqualToString:@"amount"]) {
        inAmount = YES;
    }
    if ([elementName isEqualToString:@"desc"]) {
        inDesc = YES;
    }
    if ([elementName isEqualToString:@"completed"]) {
        inCompleted = YES;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ( inName ) {
        sampleName = string;
    }
    if ( inAmount ) {
        amount = string;
    }
    if ( inDesc ) {
        desc = string;
    }
    if ( inCompleted ) {
        completed = string;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ( [elementName isEqualToString:@"sample"] ) {
        taskInfo = [NSDictionary dictionaryWithObjectsAndKeys:sampleName, @"name",amount,@"amount",desc,@"desc",sampleId,@"id",completed,@"completed",nil];
        [tasks addObject:taskInfo];
    }
    
    if ( [elementName isEqualToString:@"name"] ) {
        inName = NO;
    }
    if ( [elementName isEqualToString:@"amount"] ) {
        inAmount = NO;
    }
    if ( [elementName isEqualToString:@"desc"] ) {
        inDesc = NO;
    }
    if ( [elementName isEqualToString:@"completed"] ) {
        inCompleted = NO;
    }
}

- (IBAction)submit:(id)sender {
    self.submitButton.enabled = NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    FieldStudyAppDelegate *delegate = (FieldStudyAppDelegate *)[[UIApplication sharedApplication] delegate];
    for (int i=0; i<[tasks count];i++) {
        if ([[tasksFinished objectAtIndex:i] boolValue]==YES) {
            NSDictionary *itemAtIndex = [tasks objectAtIndex:i];
            NSString *saID = [itemAtIndex objectForKey:@"id"];
#ifdef DEVICE_SCHOOL
            NSString *url = [NSString stringWithFormat:@"http://172.29.0.199:8888/ResearchProject/server-side/update-task-status.php?user=%@&sample=%@&finish=YES",delegate.userName,saID];
#endif
            
#ifdef DEVICE_HOME
            NSString *url =[NSString stringWithFormat:@"http://192.168.0.72:8888/ResearchProject/server-side/update-task-status.php?user=%@&sample=%@&finish=YES",delegate.userName,saID];
#endif
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:url]];
            [request setHTTPMethod:@"GET"];
            
            
            conn2 =[[NSURLConnection alloc] initWithRequest:request delegate:self];
            if (conn2)
            {
                NSLog(@"connected");
                receivedData = [[NSMutableData alloc] init];
            }
            else
            {
                NSLog(@"not connected");
            }
        } else {
            NSDictionary *itemAtIndex = [tasks objectAtIndex:i];
            NSString *saID = [NSString stringWithFormat:@"%@",[itemAtIndex objectForKey:@"id"]];
#ifdef DEVICE_SCHOOL
            NSString *url = [NSString stringWithFormat:@"http://172.29.0.199:8888/ResearchProject/server-side/update-task-status.php?user=%@&sample=%@&finish=NO",delegate.userName,saID];
#endif
            
#ifdef DEVICE_HOME
            NSString *url = [NSString stringWithFormat:@"http://192.168.0.72:8888/ResearchProject/server-side/update-task-status.php?user=%@&sample=%@&finish=NO",delegate.userName,saID];
#endif
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:url]];
            [request setHTTPMethod:@"GET"];
            
            
            conn2 =[[NSURLConnection alloc] initWithRequest:request delegate:self];
            if (conn2)
            {
                NSLog(@"connected");
                receivedData = [[NSMutableData alloc] init];
            }
            else
            {
                NSLog(@"not connected");
            }
        }
    }
}



@end
