//
//  THPagingView.m
//  THPagingView
//
//  Created by Liang Huang on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "THPagingView.h"

@interface THPagingView ()

- (void)loadPageForIndex:(NSInteger)index;
- (void)unloadPageForIndex:(NSInteger)index;
- (void)setCurrentIndex:(NSInteger)index;
- (void)scrollToIndex:(NSInteger)index withAnimation:(BOOL)animation;

- (CGRect)frameForPagingView;
- (CGRect)frameForPageAtIndex:(NSInteger)index;
- (CGSize)contentSizeForPagingView;

@end

@implementation THPagingView

@synthesize pagingDelegate;

- (void)dealloc
{
    pagingDelegate = nil;
    [pageViews_ release], pageViews_ = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame 
     andPageInIndex:(NSInteger)index 
             target:(id)target
{
    self = [super initWithFrame:frame];
    if (self) {
        self.pagingDelegate = target;
        
        PADDING_ = [pagingDelegate numberOfPagePaddingInPagingView:self];
        pageCount_ = [pagingDelegate numberOfPageCountInTHPagingView:self];
        
        self.frame = [self frameForPagingView];
        self.contentSize = [self contentSizeForPagingView];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor blackColor];
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.autoresizesSubviews = YES;
        self.pagingEnabled = YES;
        self.delegate = self;
        
        pageViews_ = [[NSMutableArray alloc] init];
        for (int i = 0; i < pageCount_; i++) {
            [pageViews_ addObject:[NSNull null]];
        }
        
        [self setCurrentIndex:index];
        [self scrollToIndex:index withAnimation:NO];
    }
    return self;
}

#pragma mark-
#pragma mark controls

- (void)nextPage
{
    [self setCurrentIndex:currentIndex_ + 1];
    [self scrollToIndex:currentIndex_ withAnimation:YES];
}

- (void)prevPage
{
    [self setCurrentIndex:currentIndex_ - 1];
    [self scrollToIndex:currentIndex_ withAnimation:YES];
}


#pragma mark-
#pragma mark ScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = floor(scrollView.contentOffset.x / pageWidth);
    if (page != currentIndex_) {
        [self setCurrentIndex:page];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([pagingDelegate respondsToSelector:@selector(pagingView:didAppearPage:atIndex:)]) {
        [pagingDelegate pagingView:self didAppearPage:[pageViews_ objectAtIndex:currentIndex_] atIndex:currentIndex_];
    }
}


#pragma mark-
#pragma mark page manage

- (void)loadPageForIndex:(NSInteger)index
{
    if (index < 0 || index >= pageCount_) return;
    
    UIView *currentPage = [pageViews_ objectAtIndex:index];
    
    if ((NSNull *)currentPage == [NSNull null]) {
        currentPage = [pagingDelegate pagingView:self pageAtIndex:index];
        
        currentPage.frame = [self frameForPageAtIndex:index];
        
        [pageViews_ replaceObjectAtIndex:index withObject:currentPage];
    }
    
    if (currentPage.superview == nil) {
        [self addSubview:currentPage];
    }
}

- (void)unloadPageForIndex:(NSInteger)index
{
    if (index < 0 || index >= pageCount_) return;
    
    UIView *currentPage = [pageViews_ objectAtIndex:index];
    
    if ((NSNull *)currentPage != [NSNull null]) {
        [currentPage removeFromSuperview];
        [pageViews_ replaceObjectAtIndex:index withObject:[NSNull null]];
    }
}

- (void)setCurrentIndex:(NSInteger)index
{
    currentIndex_ = index;
    
    [self loadPageForIndex:currentIndex_];
    [self loadPageForIndex:currentIndex_ - 1];
    [self loadPageForIndex:currentIndex_ + 1];
    [self unloadPageForIndex:currentIndex_ - 2];
    [self unloadPageForIndex:currentIndex_ + 2];
}

- (void)scrollToIndex:(NSInteger)index withAnimation:(BOOL)animation
{
    CGRect frame = self.frame;
    frame.origin.x = frame.size.width * index;
    frame.origin.y = 0;
    [self scrollRectToVisible:frame animated:animation];
    
    if ([pagingDelegate respondsToSelector:@selector(pagingView:didAppearPage:atIndex:)]) {
        [pagingDelegate pagingView:self didAppearPage:[pageViews_ objectAtIndex:currentIndex_] atIndex:currentIndex_];
    }
}


#pragma mark-
#pragma mark frame calculations

- (CGRect)frameForPagingView
{
    CGRect frame = self.frame;
    frame.origin.x -= PADDING_;
    frame.size.width += (2 * PADDING_);
    return frame;
}

- (CGRect)frameForPageAtIndex:(NSInteger)index
{
    // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
    // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
    // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
    // because it has a rotation transform applied.
    CGRect bounds = self.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * PADDING_);
    pageFrame.origin.x = (bounds.size.width * index) + PADDING_;
    return pageFrame;
}

- (CGSize)contentSizeForPagingView
{
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = [self bounds];
    return CGSizeMake(bounds.size.width * pageCount_, bounds.size.height);
}


#pragma mark-
#pragma mark rotate orientation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // here, our pagingScrollView bounds have not yet been updated for the new interface orientation. So this is a good
    // place to calculate the content offset that we will need in the new orientation
    CGFloat offset = self.contentOffset.x;
    CGFloat pageWidth = self.bounds.size.width;
    
    if (offset >= 0) {
        firstVisiblePageIndexBeforeRotation_ = floorf(offset / pageWidth);
        percentScrolledIntoFirstVisiblePage_ = (offset - (firstVisiblePageIndexBeforeRotation_ * pageWidth)) / pageWidth;
    } else {
        firstVisiblePageIndexBeforeRotation_ = 0;
        percentScrolledIntoFirstVisiblePage_ = offset / pageWidth;
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // recalculate contentSize based on current orientation
    self.contentSize = [self contentSizeForPagingView];
    
    // adjust frames and configuration of each visible page
    for (int i = 0; i < pageViews_.count; i++) {
        UIView *page = [pageViews_ objectAtIndex:i];
        
        if ((NSNull *)page != [NSNull null]) {
            if ([pagingDelegate respondsToSelector:@selector(pagingView:willRotatePage:atIndex:)]) {
                [pagingDelegate pagingView:self willRotatePage:page atIndex:i];
            }
            page.frame = [self frameForPageAtIndex:i];
        }
    }
    
    // adjust contentOffset to preserve page location based on values collected prior to location
    CGFloat pageWidth = self.bounds.size.width;
    CGFloat newOffset = (firstVisiblePageIndexBeforeRotation_ * pageWidth) + (percentScrolledIntoFirstVisiblePage_ * pageWidth);
    self.contentOffset = CGPointMake(newOffset, 0);
}


@end
