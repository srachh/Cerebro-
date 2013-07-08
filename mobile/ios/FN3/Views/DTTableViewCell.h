//
//  DTCellBackgroundView.h
//  FN3
//
//  Created by David Jablonski on 3/6/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTTableViewCell : UITableViewCell {
    UIColor *startColor;
    UIColor *endColor;
}

@property (nonatomic, retain) UIColor *startColor;
@property (nonatomic, retain) UIColor *endColor;

@end
