//
//  DTButton.h
//  FN3
//
//  Created by David Jablonski on 3/5/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DTShader, DTBorder;

@interface DTButton : UIButton {
    id<DTShader> background;
    id<DTBorder>border;
    
    id<DTShader> selectedBackground;
    id<DTBorder> selectedBorder;
}

@property (nonatomic, retain) id<DTShader> background;
@property (nonatomic, retain) id<DTBorder> border;

@property (nonatomic, retain) id<DTShader> selectedBackground;
@property (nonatomic, retain) id<DTBorder> selectedBorder;

@end
