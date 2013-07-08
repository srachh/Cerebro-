//
//  DTActivityIndicatorView.m
//  FN3
//
//  Created by David Jablonski on 3/16/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTActivityIndicatorView.h"
#import <QuartzCore/QuartzCore.h>
#import "DTView.h"
#import "DTSolidShader.h"
#import "UIColor+DTColor.h"

@implementation DTActivityIndicatorView

- (id)init
{
    if (self = [super init]) {
        window = [[UIWindow alloc] init];
        
        window.windowLevel = UIWindowLevelStatusBar;
        window.exclusiveTouch = YES;
        window.hidden = YES;
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] init];
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [spinner startAnimating];
        CGSize spinnerSize = [spinner sizeThatFits:CGSizeMake(0, 0)];
        
        view = [[DTView alloc] init];
        view.frame = CGRectMake((window.bounds.size.width - 100) / 2.0, 
                                (window.bounds.size.height - 100) / 2.0, 
                                90, 
                                90);
        view.roundedCorners = DTViewRoundedCornerAll;
        view.background = [[DTSolidShader alloc] initWithColor:[[UIColor blackColor] colorWithAlphaComponent:0.8]];
        
        spinner.frame = CGRectMake((view.frame.size.width - spinnerSize.width) / 2.0, 
                                   (view.frame.size.height - spinnerSize.height) / 2.0, 
                                   spinnerSize.width, 
                                   spinnerSize.height);
        
        [view addSubview:spinner];
        [window addSubview:view];
    }
    return self;
}

- (void)dealloc
{
    window = nil;
    view = nil;
}

- (void)show
{
    window.frame = [UIScreen mainScreen].bounds;
    
    view.frame = CGRectMake((window.bounds.size.width - view.frame.size.width) / 2.0, 
                            (window.bounds.size.height - view.frame.size.height) / 2.0, 
                            view.frame.size.width, 
                            view.frame.size.height);
    
    view.alpha = 0;
    [UIView animateWithDuration:0.4 animations:^(void){
        view.alpha = 1;
    }];
    
    window.alpha = 1;
    window.hidden = NO;
}

- (void)dismiss
{
    window.hidden = YES;
}

@end
