//
//  DTField.h
//  FN3
//
//  Created by David Jablonski on 5/1/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTEditableView.h"

enum {
    DTFieldPermissionNone         = 0,
    DTFieldPermissionAvailable    = 1 << 0,
    DTFieldPermissionEditable     = 1 << 1
};
typedef NSUInteger DTFieldPermissions;


@interface DTField : DTEditableView {
    DTFieldPermissions permissions;
    
    UIPopoverController *popoverController;
}

@property (nonatomic, readonly) BOOL isEditable;
@property (nonatomic, readonly) BOOL isAvailable;
@property (nonatomic) DTFieldPermissions permissions;

- (void)setEditableFields:(NSSet *)editable availableFields:(NSSet *)available;

- (void)revert;

@end
