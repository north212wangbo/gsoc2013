//
//  AddNewChatViewController.h
//  Chat
//
//  Created by Bo Wang on 6/30/13.
//  Copyright (c) 2013 Bo Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddNewChatViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,NSXMLParserDelegate>

@property (weak, nonatomic) IBOutlet UITableView *ContactList;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *okButton;
- (IBAction)createGroup:(id)sender;


@end
