//
//  DTServiceStopField.m
//  FieldNET
//
//  Created by David Jablonski on 8/24/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTServiceStopField.h"
#import "DTLinearGradientShader.h"
#import "DTTableViewCell.h"

NSString * const DTServiceStopPermission = @"serviceStop";
NSString * const DTServiceStopAutoRepeatPermission = @"serviceStopRepeatCheckbox";

@implementation DTServiceStopField

@synthesize autoRepeat;
@synthesize isAutoRepeatAvailable;
@synthesize isAutoRepeatEditable;
@synthesize delegate;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.name = DTServiceStopPermission;
    self.minValue = 0;
    self.maxValue = 360;
    self.digits = 3;
    self.decimalPlaces = 1;
    self.nullDisplayText = @"- - -";
    
    CGSize size = CGSizeMake(16, 20);
    autoRepeatView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - size.width - 8,
                                                                   (self.frame.size.height - size.height) / 2.0,
                                                                   size.width,
                                                                   size.height)];
    autoRepeatView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:autoRepeatView];
}

- (NSString *)autoRepeatName
{
    return DTServiceStopAutoRepeatPermission;
}

- (BOOL)isAutoRepeatAvailable
{
    return (autoRepeatPermissions & DTFieldPermissionAvailable) == DTFieldPermissionAvailable;
}

- (BOOL)isAutoRepeatEditable
{
    return self.isAutoRepeatAvailable && (autoRepeatPermissions & DTFieldPermissionEditable) == DTFieldPermissionEditable;
}

- (BOOL)resignFirstResponder
{
    if (self.delegate && ![self.delegate serviceStopFieldShouldEndEditing:self]) {
        return NO;
    } else {
        return [super resignFirstResponder];
    }
}

- (void)setEditableFields:(NSSet *)editable availableFields:(NSSet *)available
{
    [super setEditableFields:editable availableFields:available];
    
    if ([editable containsObject:DTServiceStopAutoRepeatPermission]) {
        autoRepeatPermissions |= DTFieldPermissionEditable;
    }
    
    if ([available containsObject:DTServiceStopAutoRepeatPermission]) {
        autoRepeatPermissions |= DTFieldPermissionAvailable;
    }
}

- (void)setAutoRepeat:(BOOL)_autoRepeat
{
    autoRepeat = _autoRepeat;
    if (autoRepeat && self.isAutoRepeatAvailable) {
        if (self.state == DTEditableViewStateEditing) {
            autoRepeatView.image = [UIImage imageNamed:@"auto_repeat_stop"];
        } else {
            autoRepeatView.image = [UIImage imageNamed:@"auto_repeat_stop_black"];
        }
    } else {
        autoRepeatView.image = nil;
    }
}

- (void)beginEditingAnimated:(BOOL)animated
{
    [super beginEditingAnimated:animated];
    
    if (!autoRepeatValueBeforeEditing) {
        autoRepeatValueBeforeEditing = [NSNumber numberWithBool:self.autoRepeat];
    }
    self.autoRepeat = self.autoRepeat;
}

- (void)revert
{
    [super revert];
    self.autoRepeat = [autoRepeatValueBeforeEditing boolValue];
}

- (void)endEditingAnimated:(BOOL)animated
{
    [super endEditingAnimated:animated];
    
    autoRepeatValueBeforeEditing = nil;
    self.autoRepeat = self.autoRepeat;
}

- (UIView *)customInputView
{
    if (self.isAutoRepeatEditable) {
        if (!customInputView) {
            UIView *keypad = super.customInputView;
            
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                                   0,
                                                                                   self.frame.size.width,
                                                                                   keypad.frame.size.height + 70)
                                                                  style:UITableViewStyleGrouped];
            tableView.tableHeaderView = keypad;
            
            
            customInputView = tableView;
            customInputView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [(UITableView *)customInputView setDataSource:self];
            [(UITableView *)customInputView setDelegate:self];
            [(UITableView *)customInputView setScrollEnabled:NO];
            [(UITableView *)customInputView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            
            [(UITableView *)customInputView setBackgroundColor:nil];
            DTView *tableBackground = [[DTView alloc] init];
            tableBackground.background = [[DTLinearGradientShader alloc] initFromColor:[UIColor colorWithRed:.43 green:.45 blue:.51 alpha:1.0]
                                                                               toColor:[UIColor colorWithRed:.31 green:.34 blue:.39 alpha:1.0]];
            [(UITableView *)customInputView setBackgroundView:tableBackground];
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                [customInputView setFrame:CGRectMake(customInputView.frame.origin.x, customInputView.frame.origin.y, 350, customInputView.frame.size.height)];
            }
        }
        return customInputView;
    } else {
        return [super customInputView];
    }
}

-(BOOL)isValid
{
    return [super isValid];
}

- (void)switchPressed:(UISwitch *)sw {
    self.autoRepeat = sw.on;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[DTTableViewCell alloc] init];
    cell.imageView.image = [UIImage imageNamed:@"auto_repeat_stop_black.png"];
    cell.textLabel.text = NSLocalizedString(@"Auto-Repeat", nil);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UISwitch *sw = [[UISwitch alloc] init];
    sw.on = self.autoRepeat;
    [sw addTarget:self action:@selector(switchPressed:) forControlEvents:UIControlEventValueChanged];
    cell.accessoryView = sw;
    
    return cell;
}

@end
