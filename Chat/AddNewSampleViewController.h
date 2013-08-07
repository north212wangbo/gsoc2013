//
//  AddNewSampleViewController.h
//  FieldStdyForOrganizer
//
//  Created by Bo Wang on 8/4/13.
//  Copyright (c) 2013 Bo Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddNewSampleViewController : UIViewController
- (IBAction)saveNewSample:(id)sender;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UITextField *sampleTitle;
@property (weak, nonatomic) IBOutlet UITextField *amount;
@property (weak, nonatomic) IBOutlet UITextView *detail;

@end
