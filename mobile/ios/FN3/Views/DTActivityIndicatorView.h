//
//  DTActivityIndicatorView.h
//  FN3
//
//  Created by David Jablonski on 3/16/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTView;

@interface DTActivityIndicatorView : NSObject {
    UIWindow *window;
    DTView *view;
}

- (void)show;
- (void)dismiss;

@end
