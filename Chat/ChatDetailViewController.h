//
//  ChatDetailViewController.h
//  Chat
//
//  Created by Bo Wang on 6/23/13.
//  Copyright (c) 2013 Bo Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatDetailViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *messageText;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;
@property (weak, nonatomic) IBOutlet UITableView *messageList;


- (IBAction)sendClicked:(id)sender;

@end
