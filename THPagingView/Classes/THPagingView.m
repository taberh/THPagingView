//
//  THPagingView.m
//  THPagingView
//
//  Created by Liang Huang on 12-4-12.
//  Copyright (c) 2012年 iGrow. All rights reserved.
//

#import "THPagingView.h"

@interface THScrollView : UIScrollView

@end

@implementation THScrollView

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


@interface THPagingView ()

- (void)scrollToIndex:(NSInteger)aIndex withAnimation:(BOOL)animation;
- (NSInteger)exportIndex:(NSInteger)oIndex;
- (void)queueReusableCell:(UIView *)page;

- (void)loadPageForIndex:(NSInteger)index;
- (void)unloadPageForIndex:(NSInteger)index;
- (void)setCurrentIndex:(NSInteger)index;

- (CGRect)frameForPagingView;
- (CGRect)frameForPageAtIndex:(NSInteger)index;
- (CGSize)contentSizeForPagingView;

@end

@implementation THPagingView

@synthesize delegate;
@synthesize dataSource;
@synthesize supportLoop;
@synthesize index;
@synthesize startIndex;

- (void)dealloc
{
    delegate = nil;
    dataSource = nil;
    [pageViews_ release], pageViews_ = nil;
    [reusablePages_ release], reusablePages_ = nil;
    [scrollView_ setDelegate:nil];
    [scrollView_ release], scrollView_ = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        scrollView_ = [[THScrollView alloc] initWithFrame:frame];
        [scrollView_ setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [scrollView_ setBackgroundColor:[UIColor blackColor]];
        [scrollView_ setShowsVerticalScrollIndicator:NO];
        [scrollView_ setShowsHorizontalScrollIndicator:NO];
        [scrollView_ setPagingEnabled:YES];
        [scrollView_ setDelegate:self];
        
        UIView *wrapper = [[UIView alloc] initWithFrame:frame];
        [wrapper setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [wrapper setBackgroundColor:[UIColor clearColor]];
        [wrapper addSubview:scrollView_];
        [self addSubview:wrapper];
        [wrapper release], wrapper = nil;
        
        startIndex = 0;
        reusablePages_ = [[NSMutableArray alloc] init];
        pageViews_ = [[NSMutableArray alloc] init];
    }
    return self;
}


#pragma mark-
#pragma mark overwrite method

- (NSInteger)index
{
    return [self exportIndex:index];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    PADDING_ = [dataSource numberOfPaddingInPagingView:self];
    pageCount_ = [dataSource numberOfPagesInPagingView:self];
    
    if (supportLoop) {
        pageCount_ += 2;
    }
    
    [pageViews_ removeAllObjects];
    [reusablePages_ removeAllObjects];
    
    for (int i = 0; i < pageCount_; i++) {
        [pageViews_ addObject:[NSNull null]];
    }
    
    scrollView_.frame = [self frameForPagingView];
    scrollView_.contentSize = [self contentSizeForPagingView];
    
    [self scrollPageAtIndex:startIndex withAnimation:NO];
}


#pragma mark-
#pragma mark private

- (NSInteger)exportIndex:(NSInteger)oIndex
{
    if (!supportLoop) return oIndex;
    
    if (oIndex == 0) {
        oIndex = pageCount_ - 3;
    }
    else if (oIndex == (pageCount_-1)) {
        oIndex = 0;
    }
    else {
        oIndex = oIndex - 1;
    }
    
    return oIndex;
}

- (void)scrollToIndex:(NSInteger)aIndex withAnimation:(BOOL)animation
{
    [self setCurrentIndex:aIndex];
    
    CGRect frame = scrollView_.frame;
    frame.origin.x = frame.size.width * aIndex;
    frame.origin.y = 0;
    [scrollView_ scrollRectToVisible:frame animated:animation];
    
    [self scrollViewDidEndDecelerating:scrollView_];
}

- (void)queueReusableCell:(UIView *)page
{
    [reusablePages_ addObject:page];
}


#pragma mark-
#pragma mark controls

- (void)scrollPageAtIndex:(NSInteger)aIndex withAnimation:(BOOL)animation
{
    if (aIndex < 0 || 
        aIndex >= pageCount_ || 
        (supportLoop && aIndex >= (pageCount_-2))) return;
    
    if (supportLoop) {
        aIndex++; 
    }
    
    [self scrollToIndex:aIndex withAnimation:animation];
}

- (void)nextPage
{
    NSInteger aIndex = self.index + 1;
    NSInteger aSum = supportLoop ? pageCount_ - 2 : pageCount_;
    
    if (aIndex == aSum) {
        aIndex = 0;
    }
    
    [self scrollPageAtIndex:aIndex withAnimation:YES];
}

- (void)prevPage
{
    NSInteger aIndex = self.index - 1;
    NSInteger aSum = supportLoop ? pageCount_ - 2 : pageCount_;
    
    if (aIndex < 0) {
        aIndex = aSum - 1;
    }
    
    [self scrollPageAtIndex:aIndex withAnimation:YES];
}


#pragma mark-
#pragma mark publice method

- (UIView *)dequeueReusablePage
{
    UIView *page = [reusablePages_ lastObject];
    if (page) {
        [reusablePages_ removeObject:[[page retain] autorelease]];
    }
    return page;
}

- (void)reloadData
{
    startIndex = self.index;
    [self setNeedsLayout];
}


#pragma mark-
#pragma mark ScrollView delegate methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [scrollView setUserInteractionEnabled:NO];
}

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
    [scrollView setUserInteractionEnabled:YES];
    
    if (supportLoop) {
        if (index == 0) {
            [self scrollToIndex:pageCount_-2 withAnimation:NO];
            return;
        }
        else if (index == pageCount_-1) {
            [self scrollToIndex:1 withAnimation:NO];
            return;
        }
    }
    
    if ([delegate respondsToSelector:@selector(pagingView:didAppearPage:atIndex:)]) {
        [delegate pagingView:self didAppearPage:[pageViews_ objectAtIndex:index] atIndex:self.index];
    }
}


#pragma mark-
#pragma mark page manage

- (void)loadPageForIndex:(NSInteger)index_
{
    if (index_ < 0 || index_ >= pageCount_) return;
    
    UIView *page = [pageViews_ objectAtIndex:index_];
    
    if ((NSNull *)page == [NSNull null]) {
        page = [delegate pagingView:self pageAtIndex:[self exportIndex:index_]];
        [page setFrame:[self frameForPageAtIndex:index_]];
        [pageViews_ replaceObjectAtIndex:index_ withObject:page];
    }
    
    if (page.superview == nil) {
        [scrollView_ addSubview:page];
    }
}

- (void)unloadPageForIndex:(NSInteger)index_
{
    if (index_ < 0 || index_ >= pageCount_) return;
    
    UIView *page = [pageViews_ objectAtIndex:index_];
    
    if ((NSNull *)page != [NSNull null]) {
        [self queueReusableCell:page];
        
        if ([page superview]) {
            [page removeFromSuperview];
        }
        
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
    CGRect frame = [scrollView_ frame];
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
    CGRect bounds = [scrollView_ bounds];
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * PADDING_);
    pageFrame.origin.x = (bounds.size.width * index_) + PADDING_;
    return pageFrame;
}

- (CGSize)contentSizeForPagingView
{
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = [scrollView_ bounds];
    return CGSizeMake(bounds.size.width * pageCount_, bounds.size.height);
}


#pragma mark-
#pragma mark rotate orientation

/*- (void)willRotate:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration
 {
 // here, our pagingView bounds have not yet been updated for the new interface orientation. So this is a good
 // place to calculate the content offset that we will need in the new orientation
 CGFloat offset = scrollView_.contentOffset.x;
 CGFloat pageWidth = scrollView_.bounds.size.width;
 
 if (offset >= 0) {
 firstVisiblePageIndexBeforeRotation_ = floorf(offset / pageWidth);
 percentScrolledIntoFirstVisiblePage_ = (offset - (firstVisiblePageIndexBeforeRotation_ * pageWidth)) / pageWidth;
 } else {
 firstVisiblePageIndexBeforeRotation_ = 0;
 percentScrolledIntoFirstVisiblePage_ = offset / pageWidth;
 }
 }
 
 - (void)willAnimateRotation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration
 {
 // recalculate contentSize based on current orientation
 scrollView_.contentSize = [self contentSizeForPagingView];
 
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
 CGFloat pageWidth = scrollView_.bounds.size.width;
 CGFloat newOffset = (firstVisiblePageIndexBeforeRotation_ * pageWidth) + (percentScrolledIntoFirstVisiblePage_ * pageWidth);
 scrollView_.contentOffset = CGPointMake(newOffset, 0);
 }*/

@end
