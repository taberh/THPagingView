//
//  THPagingView.h
//  THPagingView
//
//  Created by Liang Huang on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class THPagingView;

@protocol THPagingViewDelegate <UIScrollViewDelegate>

@required
- (NSInteger)numberOfPageCountInTHPagingView:(THPagingView *)pagingView;
- (NSInteger)numberOfPagePaddingInPagingView:(THPagingView *)pagingView;
- (UIView *)pagingView:(THPagingView *)pagingView 
                 index:(NSInteger)index
                 frame:(CGRect)frame;

@optional
- (void)pagingView:(THPagingView *)pagingView 
           didAppearPage:(UIView *)page 
                 atIndex:(NSInteger)index;
- (void)pagingView:(THPagingView *)pagingView 
          willRotatePage:(UIView *)page 
                 atIndex:(NSInteger)index;

@end


@interface THPagingView : UIScrollView <UIScrollViewDelegate>
{
    NSMutableArray *pageViews_;
    NSInteger pageCount_;
    NSInteger PADDING_;
    NSInteger startIndex_;
    
    // these values are stored off before we start rotation so we adjust our content offset appropriately during rotation
    int firstVisiblePageIndexBeforeRotation_;
    CGFloat percentScrolledIntoFirstVisiblePage_;
}

@property (strong, nonatomic) id <THPagingViewDelegate> delegate;
@property (readonly, nonatomic) NSInteger index;

- (id)initWithFrame:(CGRect)frame target:(id)target index:(NSInteger)index;

- (void)scrollToIndex:(NSInteger)index withAnimation:(BOOL)animation;
- (void)nextPage;
- (void)prevPage;

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                duration:(NSTimeInterval)duration;

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration;

@end
