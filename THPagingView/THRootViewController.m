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

- (NSInteger)numberOfPagesInPagingView:(THPagingView *)pagingView
{
    return 10;
}

- (NSInteger)numberOfPaddingInPagingView:(THPagingView *)pagingView
{
    return 10;
}

- (UIView *)pagingView:(THPagingView *)pagingView pageAtIndex:(NSInteger)index
{
    UIView *page = [pagingView dequeueReusablePage];
    
    if (!page) {
        page = [[[UIView alloc] init] autorelease];
    }
    
    switch (index) {
        case 0:
            page.backgroundColor = [UIColor blueColor];
            break;
        case 1:
            page.backgroundColor = [UIColor redColor];
            break;
        case 2:
            page.backgroundColor = [UIColor yellowColor];
            break;
        case 3:
            page.backgroundColor = [UIColor grayColor];
            break;
        case 4:
            page.backgroundColor = [UIColor orangeColor];
            break;
        case 5:
            page.backgroundColor = [UIColor purpleColor];
            break;
        case 6:
            page.backgroundColor = [UIColor blackColor];
            break;
        case 7:
            page.backgroundColor = [UIColor whiteColor];
            break;
        case 8:
            page.backgroundColor = [UIColor greenColor];
            break;
        case 9:
            page.backgroundColor = [UIColor magentaColor];
            break;
    }
    
    return page;
}

- (void)pagingView:(THPagingView *)pagingView didAppearPage:(UIView *)page atIndex:(NSInteger)index
{
    //NSLog(@"show %i", index);
    //NSLog(@"index %i", pagingView_.index);
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self setWantsFullScreenLayout:YES];
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    pagingView_ = [[THPagingView alloc] initWithFrame:frame];
    pagingView_.startIndex = 0;
    pagingView_.supportLoop = YES;
    pagingView_.delegate = self;
    pagingView_.dataSource = self;
    pagingView_.enabledIndicator = YES;
    [self.view addSubview:pagingView_];
    [pagingView_ release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //[pagingView_ willRotate:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //[pagingView_ willAnimateRotation:toInterfaceOrientation duration:duration];
}

@end
