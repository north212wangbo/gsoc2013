//
//  OrganizerTaskViewController.h
//  FieldStdy
//
//  Created by Bo Wang on 7/31/13.
//  Copyright (c) 2013 Bo Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrganizerTaskViewController : UITableViewController <NSXMLParserDelegate>
- (IBAction)refresh:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;


@end
