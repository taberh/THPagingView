//
//  THPagingView.h
//  THPagingView
//
//  Created by Liang Huang on 12-4-12.
//  Copyright (c) 2012年 iGrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@class THScrollView;
@protocol THPagingViewDelegate;
@protocol THPagingViewDataSource;


@interface THPagingView : UIView <UIScrollViewDelegate>
{
    THScrollView *scrollView_;
    NSMutableArray *reusablePages_;
    NSMutableArray *pageViews_;
    NSInteger pageCount_;
    NSInteger PADDING_;
    
    //int firstVisiblePageIndexBeforeRotation_;
    //CGFloat percentScrolledIntoFirstVisiblePage_;
}

@property (assign, nonatomic) id <THPagingViewDelegate> delegate;
@property (assign, nonatomic) id <THPagingViewDataSource> dataSource;
@property (readonly, nonatomic) NSInteger index;
@property (assign, nonatomic) NSInteger startIndex;
@property (assign, nonatomic) BOOL supportLoop;

- (void)scrollPageAtIndex:(NSInteger)aIndex withAnimation:(BOOL)animation;
- (void)nextPage;
- (void)prevPage;
- (UIView *)dequeueReusablePage;
- (void)reloadData;
//- (void)willRotate:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration;
//- (void)willAnimateRotation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration;

@end


@protocol THPagingViewDataSource <NSObject>

- (NSInteger)numberOfPagesInPagingView:(THPagingView *)pagingView;
- (NSInteger)numberOfPaddingInPagingView:(THPagingView *)pagingView ;

@end


@protocol THPagingViewDelegate <UIScrollViewDelegate>

@required
- (UIView *)pagingView:(THPagingView *)pagingView pageAtIndex:(NSInteger)index;

@optional
- (void)pagingView:(THPagingView *)pagingView didAppearPage:(UIView *)page atIndex:(NSInteger)index;
//- (void)pagingView:(THPagingView *)pagingView willRotatePage:(UIView *)page atIndex:(NSInteger)index;

@end
