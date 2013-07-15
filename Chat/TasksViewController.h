//
//  TasksViewController.h
//  FieldStdy
//
//  Created by Bo Wang on 7/10/13.
//  Copyright (c) 2013 Bo Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TasksViewController : UITableViewController <NSXMLParserDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *submitButton;
@property (strong, nonatomic) IBOutlet UITableView *TaskTableView;
- (IBAction)submit:(id)sender;

@end
