//
//  OrganizerTaskDetailViewController.m
//  FieldStdy
//
//  Created by Bo Wang on 7/31/13.
//  Copyright (c) 2013 Bo Wang. All rights reserved.
//

#import "OrganizerTaskDetailViewController.h"
#import "OrganizerTaskEditViewController.h"
#import "AssignTaskViewController.h"
#import "FieldStudyAppDelegate.h"
#define DEVICE_SCHOOL
//#define DEVICE_HOME

@interface OrganizerTaskDetailViewController () {
    NSMutableArray *tasks;
    
    NSMutableData *receivedData;
    NSXMLParser *parser;
    NSURLConnection *conn,*deleteConn;
    
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

@implementation OrganizerTaskDetailViewController

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
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(addTask)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.editButtonItem,addButton, nil];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(getTaskList) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
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
    
    NSDictionary *itemAtIndex = (NSDictionary *)[tasks objectAtIndex:indexPath.row];
    if ([[itemAtIndex objectForKey:@"completed"] isEqualToString:@"1"]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (completed)",[itemAtIndex objectForKey:@"name"]];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (in progress)",[itemAtIndex objectForKey:@"name"]];
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.text = [itemAtIndex objectForKey:@"desc"];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    
    return cell;
}

#pragma mark - Table view delegate and segue

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
    //TaskDetailViewController *detailViewController = [[TaskDetailViewController alloc] init];
    // ...
    // Pass the selected object to the new view controller.
    //[self.navigationController pushViewController:detailViewController animated:YES];
    
    [self performSegueWithIdentifier:@"OrganizerTaskEditViewSegue" sender:self];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if ([segue.identifier isEqualToString:@"OrganizerTaskEditViewSegue"]) {
        OrganizerTaskEditViewController *controller = segue.destinationViewController;
        NSDictionary *itemAtIndex = (NSDictionary *)[tasks objectAtIndex:indexPath.row];
        controller.sampleTitleText = [itemAtIndex objectForKey:@"name"];
        controller.amountText = [itemAtIndex objectForKey:@"amount"];
        controller.detailText = [itemAtIndex objectForKey:@"desc"];
        controller.sampleId = [itemAtIndex objectForKey:@"id"];
        controller.hidesBottomBarWhenPushed = YES;
    }
    
    if ([segue.identifier isEqualToString:@"OrganizerTaskAddViewSegue"]) {
        AssignTaskViewController *controller = segue.destinationViewController;
        controller.studentId = self.user;
    }
}

#pragma mark - get task list

-(void)getTaskList{
#ifdef DEVICE_SCHOOL
    NSString *url = [NSString stringWithFormat:@"http://69.166.62.3/~bowang/gsoc/get-student-tasks.php?user=%@",self.user];
    
#endif
    
#ifdef DEVICE_HOME
    NSString *url = [NSString stringWithFormat:@"http://192.168.0.72:8888/ResearchProject/server-side/get-student-tasks.php?user=%@",self.user];
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
        if ( tasks == nil )
            tasks = [[NSMutableArray alloc] init];
        
        [tasks removeAllObjects];  //remove the record of previous user, should find better way
        parser = [[NSXMLParser alloc] initWithData:receivedData];
        [parser setDelegate:self];
        [parser parse];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }
    
    if (connection == deleteConn) {
        NSLog(@"delete finished");
        
        FieldStudyAppDelegate *delegate = (FieldStudyAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
        [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        NSString *log = [NSString stringWithFormat:@"%@ Task deleted!\n",[DateFormatter stringFromDate:[NSDate date]]];
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPath];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
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

#pragma mark - Edit button

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteTaskForRowAtIndexPath:indexPath];
        [tasks removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Delete/Add Task

-(void)deleteTaskForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *itemAtIndex = (NSDictionary *)[tasks objectAtIndex:indexPath.row];
    NSString *taskId = [itemAtIndex objectForKey:@"id"];
#ifdef DEVICE_SCHOOL
    NSString *url = [NSString stringWithFormat:@"http://69.166.62.3/~bowang/gsoc/delete-task.php?user=%@&task=%@",self.user,taskId];
    
#endif
    
#ifdef DEVICE_HOME
    NSString *url = [NSString stringWithFormat:@"http://192.168.0.72:8888/ResearchProject/server-side/delete-task.php?user=%@&task=%@",self.user,taskId];
#endif
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    deleteConn =[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (deleteConn)
    {
        NSLog(@"delete connected");
        receivedData = [[NSMutableData alloc] init];
    }
    else
    {
        NSLog(@"not connected");
    }
}

-(void)addTask {
    [self performSegueWithIdentifier:@"OrganizerTaskAddViewSegue" sender:self];
}

@end
