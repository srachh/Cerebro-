//
//  DTAutoControlsView.m
//  FN3
//
//  Created by David Jablonski on 4/28/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTAutoControlsView.h"

#import "DTView.h"
#import "DTLinearGradientShader.h"
#import "DTTableViewCell.h"

#import "UIColor+DTColor.h"


NSString * const DTAutoControlAutoRestartName = @"autoRestartCheckbox";
NSString * const DTAutoControlAutoReverseName = @"autoReverseSelect";


@interface DTAutoControlsViewField : NSObject {
    NSString *name;
    UIImageView *view;
    UIImage *image, *highlightedImage;
    BOOL value;
    NSNumber *valueBeforeEditing;
    DTFieldPermissions permissions;
    UISwitch *control;
}
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) UIImageView *view;
@property (nonatomic, retain) UIImage *image, *highlightedImage;
@property (nonatomic) BOOL value;
@property (nonatomic) DTFieldPermissions permissions;
@property (nonatomic, retain) NSNumber *valueBeforeEditing;
@property (nonatomic, readonly) BOOL isAvailable, isEditable;
@property (nonatomic, retain) UISwitch *control;
@end

@implementation DTAutoControlsViewField
@synthesize name, view, control, image, highlightedImage, value, permissions, valueBeforeEditing;

- (BOOL)isEditable
{
    return (self.permissions & DTFieldPermissionEditable) == DTFieldPermissionEditable;
}

- (BOOL)isAvailable
{
    return (self.permissions & DTFieldPermissionAvailable) == DTFieldPermissionAvailable;
}

@end


@implementation DTAutoControlsView

@synthesize autoReverse, autoRestart;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    autoRestartField = [[DTAutoControlsViewField alloc] init];
    autoRestartField.name = NSLocalizedString(@"Auto-Restart", @"Auto-restart toggle label");
    autoRestartField.image = [UIImage imageNamed:@"autorestart.png"];
    autoRestartField.view = [[UIImageView alloc] initWithImage:autoRestartField.image];
    autoRestartField.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    autoRestartField.highlightedImage = [UIImage imageNamed:@"autorestart_selected.png"];
    autoRestartField.control = [[UISwitch alloc] init];
    [autoRestartField.control addTarget:self action:@selector(autoRestartSwitchPressed:) forControlEvents:UIControlEventValueChanged];
    
    autoReverseField = [[DTAutoControlsViewField alloc] init];
    autoReverseField.name = NSLocalizedString(@"Auto-Reverse", @"Auto-Reverse toggle label");
    autoReverseField.image = [UIImage imageNamed:@"autoreverse.png"];
    autoReverseField.view = [[UIImageView alloc] initWithImage:autoReverseField.image];
    autoReverseField.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    autoReverseField.highlightedImage = [UIImage imageNamed:@"autoreverse_selected.png"];
    autoReverseField.control = [[UISwitch alloc] init];
    [autoReverseField.control addTarget:self action:@selector(autoReverseSwitchPressed:) forControlEvents:UIControlEventValueChanged];
    
    visibleControls = [[NSMutableArray alloc] initWithCapacity:2];
    [visibleControls addObject:autoRestartField];
    [visibleControls addObject:autoReverseField];
    [self layoutControls];
}

- (void)layoutControls
{
    [autoReverseField.view removeFromSuperview];
    [autoRestartField.view removeFromSuperview];
    
    CGFloat width = self.frame.size.width / visibleControls.count;
    for (int i = 0; i < visibleControls.count; i++) {
        DTAutoControlsViewField *field = [visibleControls objectAtIndex:i];
        CGFloat xOffset = width * i;
        
        field.view.frame = CGRectMake(xOffset + ((width - 20) / 2.0), 
                                      (self.frame.size.height - 20) / 2.0, 
                                      20, 
                                      20);
        [self addSubview:field.view];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (UIView *)inputView
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return nil;
    } else {
        return self.customInputView;
    }
}

- (UIView *)customInputView
{
    if (!customInputView) {
        customInputView = [[UITableView alloc]  initWithFrame:CGRectMake(0, 0, self.frame.size.width, (visibleControls.count * 70) + 50) 
                                                             style:UITableViewStyleGrouped];
        [(UITableView *)customInputView setDataSource:self];
        [(UITableView *)customInputView setDelegate:self];
        [(UITableView *)customInputView setScrollEnabled:NO];
        [(UITableView *)customInputView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        [(UITableView *)customInputView setBackgroundColor:nil];
        DTView *tableBackground = [[DTView alloc] init];
        tableBackground.background = [[DTLinearGradientShader alloc] initFromColor:[UIColor colorWithRed:.43 green:.45 blue:.51 alpha:1.0] 
                                                                           toColor:[UIColor colorWithRed:.31 green:.34 blue:.39 alpha:1.0]];
        [(UITableView *)customInputView setBackgroundView:tableBackground];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) 
        {
            [customInputView setFrame:CGRectMake(customInputView.frame.origin.x, customInputView.frame.origin.y, 350, customInputView.frame.size.height)];
        }
    } else {
        [(UITableView *)customInputView reloadData];
    }

    
    return customInputView;
}

- (void)setEditableFields:(NSSet *)editable availableFields:(NSSet *)available
{
    self.permissions = autoRestartField.permissions = autoReverseField.permissions = DTFieldPermissionNone;
    [visibleControls removeAllObjects];
    
    // set the permissions for each field
    if ([editable containsObject:DTAutoControlAutoRestartName]) {
        autoRestartField.permissions |= DTFieldPermissionEditable;
    }
    if ([editable containsObject:DTAutoControlAutoReverseName]) {
        autoReverseField.permissions |= DTFieldPermissionEditable;
    }
    
    if ([available containsObject:DTAutoControlAutoRestartName]) {
        autoRestartField.permissions |= DTFieldPermissionAvailable;
        [visibleControls addObject:autoRestartField];
    }
    if ([available containsObject:DTAutoControlAutoReverseName]) {
        autoReverseField.permissions |= DTFieldPermissionAvailable;
        [visibleControls addObject:autoReverseField];
    }
    
    // set the overall permissions
    if (autoRestartField.isAvailable || autoReverseField.isAvailable) {
        self.permissions |= DTFieldPermissionAvailable;
    }
    if (autoRestartField.isEditable || autoReverseField.isEditable) {
        self.permissions |= DTFieldPermissionEditable;
    }
    
    [self layoutControls];
}

- (void)setAutoReverse:(BOOL)_autoReverse
{
    autoReverseField.value = _autoReverse;
    if (_autoReverse) {
        autoReverseField.view.image = autoReverseField.highlightedImage;
    } else {
        autoReverseField.view.image = autoReverseField.image;
    }
}

- (void)autoReverseSwitchPressed:(UISwitch *)sw {
    self.autoReverse = sw.on;
}

- (void)autoRestartSwitchPressed:(UISwitch *)sw {
    self.autoRestart = sw.on;
}

- (void)setAutoRestart:(BOOL)_autoRestart
{
    autoRestartField.value = _autoRestart;
    if (_autoRestart) {
        autoRestartField.view.image = autoRestartField.highlightedImage;
    } else {
        autoRestartField.view.image = autoRestartField.image;
    }
}

- (void)beginEditingAnimated:(BOOL)animated
{
    [super beginEditingAnimated:animated];
    
    if (!autoRestartField.valueBeforeEditing) {
        autoRestartField.valueBeforeEditing = [NSNumber numberWithBool:autoRestartField.value];
    }
    
    if (!autoReverseField.valueBeforeEditing) {
        autoReverseField.valueBeforeEditing = [NSNumber numberWithBool:autoReverseField.value];
    }
}

- (void)revert
{
    self.autoRestart = [autoRestartField.valueBeforeEditing boolValue];
    self.autoReverse = [autoReverseField.valueBeforeEditing boolValue];
}

- (void)endEditingAnimated:(BOOL)animated
{
    [super endEditingAnimated:animated];
    
    autoRestartField.valueBeforeEditing = nil;
    autoReverseField.valueBeforeEditing = nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return visibleControls.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[DTTableViewCell alloc] init];
    [cell awakeFromNib];
    
    DTAutoControlsViewField *field = [visibleControls objectAtIndex:indexPath.row];
    cell.imageView.image = field.image;
    cell.textLabel.text = field.name;
    if (field.isEditable) {
        field.control.on = field.value;
        cell.accessoryView = field.control;
    } else {
        UILabel *label = [[UILabel alloc] init];
        label.text = NSLocalizedString(field.value ? @"On" : @"Off", nil);
        cell.accessoryView = label;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

@end
