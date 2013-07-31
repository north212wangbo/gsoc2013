//
//  TaskDetailViewController.m
//  FieldStdy
//
//  Created by Bo Wang on 7/10/13.
//  Copyright (c) 2013 Bo Wang. All rights reserved.
//

#import "TaskDetailViewController.h"

@interface TaskDetailViewController () {
    NSString *description;
}

@end

@implementation TaskDetailViewController

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
    [self hidesBottomBarWhenPushed];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    description = [prefs stringForKey:self.taskId];
	self.taskDetail.text = description;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneEditting:(id)sender {
    description = self.taskDetail.text;
    [[NSUserDefaults standardUserDefaults] setObject:description forKey:self.taskId];
    [self.taskDetail resignFirstResponder];
}
@end
