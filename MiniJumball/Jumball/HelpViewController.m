//
//  HelpViewController.m
//  Jumball
//
//  Created by Li Xu on 10/17/12.
//  Copyright (c) 2012 Li Xu. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()

@end

@implementation HelpViewController

@synthesize scrollView;

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

    UIColor* blue = [UIColor colorWithRed:204.0 / 255.0 green:224.0 / 255.0 blue:244.0 / 255.0 alpha:1.0f];
    self.view.backgroundColor = blue;
    
    NSArray* nibNames = [NSArray arrayWithObjects:@"BeginNewGame", @"CallUpRobots", @"MoveRules", @"Step1", @"Step2", @"Step3", nil];
    CGSize viewSize = self.view.bounds.size;
    for (int i = 0; i < nibNames.count; ++i)
    {
        UIViewController* viewController = [[[UIViewController alloc] initWithNibName:[nibNames objectAtIndex:i] bundle:nil] autorelease];
        UIView* view = viewController.view;
        view.frame = CGRectMake(i * viewSize.width, 0, viewSize.width, viewSize.height);
        [self.scrollView addSubview:view];
    }
    self.scrollView.contentSize = CGSizeMake(viewSize.width * nibNames.count, viewSize.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}


- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
