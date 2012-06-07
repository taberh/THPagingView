//
//  THRootViewController.h
//  THPagingView
//
//  Created by Liang Huang on 12-4-12.
//  Copyright (c) 2012年 iGrow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THPagingView.h"

@interface THRootViewController : UIViewController <THPagingViewDelegate, THPagingViewDataSource>
{
    THPagingView *pagingView_;
}

@end
