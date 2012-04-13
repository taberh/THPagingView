//
//  THRootViewController.h
//  THPagingView
//
//  Created by Liang Huang on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THPagingView.h"

@interface THRootViewController : UIViewController <THPagingViewDelegate>
{
    THPagingView *pagingView_;
}

@end
