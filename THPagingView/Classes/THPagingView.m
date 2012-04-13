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

- (CGRect)frameForPagingView;
- (CGRect)frameForPageAtIndex:(NSInteger)index;
- (CGSize)contentSizeForPagingView;

@end

@implementation THPagingView

@synthesize delegate, index;

- (void)dealloc
{
    delegate = nil;
    [pageViews_ release], pageViews_ = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame target:(id)target index:(NSInteger)startIndex
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = target;
        
        PADDING_ = [delegate numberOfPagePaddingInPagingView:self];
        pageCount_ = [delegate numberOfPageCountInTHPagingView:self];
        
        self.frame = [self frameForPagingView];
        self.contentSize = [self contentSizeForPagingView];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor blackColor];
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.autoresizesSubviews = YES;
        self.pagingEnabled = YES;
        [super setDelegate:self];
        
        pageViews_ = [[NSMutableArray alloc] init];
        for (int i = 0; i < pageCount_; i++) {
            [pageViews_ addObject:[NSNull null]];
        }
        
        [self setCurrentIndex:startIndex];
        [self scrollToIndex:startIndex withAnimation:NO];
    }
    return self;
}

#pragma mark-
#pragma mark controls

- (void)nextPage
{
    [self setCurrentIndex:index + 1];
    [self scrollToIndex:index withAnimation:YES];
}

- (void)prevPage
{
    [self setCurrentIndex:index - 1];
    [self scrollToIndex:index withAnimation:YES];
}

- (void)scrollToIndex:(NSInteger)index_ withAnimation:(BOOL)animation
{
    CGRect frame = self.frame;
    frame.origin.x = frame.size.width * index_;
    frame.origin.y = 0;
    [self scrollRectToVisible:frame animated:animation];
    
    if ([delegate respondsToSelector:@selector(pagingView:didAppearPage:atIndex:)]) {
        [delegate pagingView:self didAppearPage:[pageViews_ objectAtIndex:index] atIndex:index];
    }
}


#pragma mark-
#pragma mark ScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = floor(scrollView.contentOffset.x / pageWidth);
    if (page != index) {
        [self setCurrentIndex:page];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([delegate respondsToSelector:@selector(pagingView:didAppearPage:atIndex:)]) {
        [delegate pagingView:self didAppearPage:[pageViews_ objectAtIndex:index] atIndex:index];
    }
}


#pragma mark-
#pragma mark page manage

- (void)loadPageForIndex:(NSInteger)index_
{
    if (index_ < 0 || index_ >= pageCount_) return;
    
    UIView *currentPage = [pageViews_ objectAtIndex:index_];
    
    if ((NSNull *)currentPage == [NSNull null]) {
        currentPage = [delegate pagingView:self pageAtIndex:index_];
        
        currentPage.frame = [self frameForPageAtIndex:index_];
        
        [pageViews_ replaceObjectAtIndex:index_ withObject:currentPage];
        
        [currentPage release];
    }
    
    if (currentPage.superview == nil) {
        [self addSubview:currentPage];
    }
}

- (void)unloadPageForIndex:(NSInteger)index_
{
    if (index_ < 0 || index_ >= pageCount_) return;
    
    UIView *currentPage = [pageViews_ objectAtIndex:index_];
    
    if ((NSNull *)currentPage != [NSNull null]) {
        [currentPage removeFromSuperview];
        [pageViews_ replaceObjectAtIndex:index_ withObject:[NSNull null]];
    }
}

- (void)setCurrentIndex:(NSInteger)index_
{
    index = index_;
    
    [self loadPageForIndex:index];
    [self loadPageForIndex:index - 1];
    [self loadPageForIndex:index + 1];
    [self unloadPageForIndex:index - 2];
    [self unloadPageForIndex:index + 2];
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

- (CGRect)frameForPageAtIndex:(NSInteger)index_
{
    // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
    // landscape orientation, the frame will still be in portrait because the pagingView is the root view controller's
    // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
    // because it has a rotation transform applied.
    CGRect bounds = self.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * PADDING_);
    pageFrame.origin.x = (bounds.size.width * index_) + PADDING_;
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
    // here, our pagingView bounds have not yet been updated for the new interface orientation. So this is a good
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
            if ([delegate respondsToSelector:@selector(pagingView:willRotatePage:atIndex:)]) {
                [delegate pagingView:self willRotatePage:page atIndex:i];
            }
            page.frame = [self frameForPageAtIndex:i];
        }
    }
    
    // adjust contentOffset to preserve page location based on values collected prior to location
    CGFloat pageWidth = self.bounds.size.width;
    CGFloat newOffset = (firstVisiblePageIndexBeforeRotation_ * pageWidth) + (percentScrolledIntoFirstVisiblePage_ * pageWidth);
    self.contentOffset = CGPointMake(newOffset, 0);
}


#pragma mark-
#pragma mark override touch event

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{	
    if(!self.dragging) {
        [[self nextResponder] touchesEnded:touches withEvent:event];
    }
    
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if(!self.dragging) {
        [[self nextResponder] touchesBegan:touches withEvent:event];
    }
    
    [super touchesBegan:touches withEvent:event];
    
}

@end
