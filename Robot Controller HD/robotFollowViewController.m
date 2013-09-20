//
//  robotFollowViewController.m
//  Robot Controller HD
//
//  Created by 龚儒雅 on 13-8-25.
//  Copyright (c) 2013年 Gong Ruya. All rights reserved.
//

#import "robotFollowViewController.h"

@interface robotFollowViewController ()

@end

@implementation robotFollowViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)StartFollowButton {
    NSLog(@"Follow");
}
@end
