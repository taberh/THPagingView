//
//  THRootViewController.m
//  THPagingScrollView
//
//  Created by Liang Huang on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "THRootViewController.h"

@implementation THRootViewController

- (void)dealloc
{
    [pagingView_ release], pagingView_ = nil;
    [super dealloc];
}

- (NSInteger)numberOfPageCountInTHPagingView:(THPagingView *)pagingView
{
    return 6;
}

- (NSInteger)numberOfPagePaddingInPagingView:(THPagingView *)pagingView
{
    return 10;
}

- (UIView *)pagingView:(THPagingView *)pagingView index:(NSInteger)index frame:(CGRect)frame
{
    UIView *view = [[[UIView alloc] initWithFrame:frame] autorelease];
    
    switch (index) {
        case 0:
            view.backgroundColor = [UIColor blueColor];
            break;
        case 1:
            view.backgroundColor = [UIColor redColor];
            break;
        case 2:
            view.backgroundColor = [UIColor yellowColor];
            break;
        case 3:
            view.backgroundColor = [UIColor grayColor];
            break;
        case 4:
            view.backgroundColor = [UIColor orangeColor];
            break;
        case 5:
            view.backgroundColor = [UIColor purpleColor];
            break;
    }
    
    return view;
}

- (void)pagingView:(THPagingView *)pagingView didAppearPage:(UIView *)page atIndex:(NSInteger)index
{
    NSLog(@"show %i", index);
}

- (void)pagingView:(THPagingView *)pagingView willRotatePage:(UIView *)page atIndex:(NSInteger)index
{
    NSLog(@"retate %i", index);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect frame = [[UIScreen mainScreen] bounds];
    pagingView_ = [[THPagingView alloc] initWithFrame:frame target:self index:0];
    [self.view addSubview:pagingView_];
    [pagingView_ release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [pagingView_ willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [pagingView_ willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

@end
