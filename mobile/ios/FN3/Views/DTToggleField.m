//
//  DTToggleField.m
//  FN3
//
//  Created by David Jablonski on 5/31/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTToggleField.h"
#import "DTLinearGradientShader.h"
#import "DTTableViewCell.h"

@implementation DTToggleField

@synthesize on, name, title;
@synthesize onImage, offImage, toggleImage;
@synthesize delegate;

- (void)awakeFromNib
{
    CGSize size = CGSizeMake(36, 36);
    view = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - size.width) / 2.0, 
                                                         (self.frame.size.height - size.height) / 2.0, 
                                                         size.width, 
                                                         size.height)];
    view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:view];
}

- (void)setEditableFields:(NSSet *)editable availableFields:(NSSet *)available
{
    permissions = 0;
    
    if ([editable containsObject:self.name]) {
        permissions |= DTFieldPermissionEditable;
    }
    
    if ([available containsObject:self.name]) {
        permissions |= DTFieldPermissionAvailable;
    }
    
    view.hidden = !self.isAvailable;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)resignFirstResponder
{
    if (self.delegate && ![self.delegate toggleFieldShouldEndEditing:self]) {
        return NO;
    } else {
        return [super resignFirstResponder];
    }
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
        customInputView = [[UITableView alloc]  initWithFrame:CGRectMake(0, 0, self.frame.size.width, 120) 
                                                             style:UITableViewStyleGrouped];
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
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) 
        {
            [customInputView setFrame:CGRectMake(customInputView.frame.origin.x, customInputView.frame.origin.y, 350, customInputView.frame.size.height)];
        }
        
    } else {
        [(UITableView *)customInputView reloadData];
    }
    return customInputView;
}

- (void)setOn:(BOOL)_on
{
    on = _on;
    if (on) {
        view.image = self.onImage;
    } else {
        view.image = self.offImage;
    }
}

- (void)setInputChangeTarget:(id)target selector:(SEL)selector
{
    NSMethodSignature * sig = [[target class] instanceMethodSignatureForSelector:selector];
    inputChangeListener = [NSInvocation invocationWithMethodSignature:sig];
    inputChangeListener.target = target;
    inputChangeListener.selector = selector;
}

- (void)beginEditingAnimated:(BOOL)animated
{
    [super beginEditingAnimated:animated];
    
    if (!valueBeforeEditing) {
        valueBeforeEditing = [NSNumber numberWithBool:self.on];
    }
}

- (void)revert
{
    self.on = [valueBeforeEditing boolValue];
}

- (void)endEditingAnimated:(BOOL)animated
{
    [super endEditingAnimated:animated];
    
    valueBeforeEditing = nil;
}

- (void)switchPressed:(UISwitch *)sw {
    BOOL valueChanged = NO;
    
    if (self.on != sw.on) {
        valueChanged = YES;
    }
    
    self.on = sw.on;
    
    if (valueChanged) {
        id this = self;
        [inputChangeListener setArgument:&this atIndex:2];
            [inputChangeListener invoke];
    }
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
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[DTTableViewCell alloc] init];
    cell.imageView.image = self.toggleImage;
    cell.textLabel.text = self.title;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UISwitch *sw = [[UISwitch alloc] init];
    sw.on = self.on;
    [sw addTarget:self action:@selector(switchPressed:) forControlEvents:UIControlEventValueChanged];
    cell.accessoryView = sw;
    
    return cell;
}
@end
