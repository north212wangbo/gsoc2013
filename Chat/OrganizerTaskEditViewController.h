//
//  OrganizerTaskEditViewController.h
//  FieldStdy
//
//  Created by Bo Wang on 7/31/13.
//  Copyright (c) 2013 Bo Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrganizerTaskEditViewController : UIViewController

@property (copy, nonatomic) NSString *sampleTitleText;
@property (copy, nonatomic) NSString *amountText;
@property (copy, nonatomic) NSString *detailText;
@property (copy, nonatomic) NSString *sampleId;

@property (weak, nonatomic) IBOutlet UITextField *sampleTitle;
@property (weak, nonatomic) IBOutlet UITextField *amount;
@property (weak, nonatomic) IBOutlet UITextView *detail;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

- (IBAction)saveEdit:(id)sender;

@end
