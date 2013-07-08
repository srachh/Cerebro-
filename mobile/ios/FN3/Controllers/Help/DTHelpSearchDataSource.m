//
//  DTHelpSearchDataSource.m
//  FN3
//
//  Created by David Jablonski on 5/23/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTHelpSearchDataSource.h"
#import "DTSearchTableDisplayController.h"
#import "DTTableViewCell.h"
#import "UIView+DTCustomViews.h"

@implementation DTHelpSearchDataSource

@synthesize searchDisplayController;

- (id)initWithTableView:(UITableView *)tableView
{
    if (self = [super init]) {
        sourceTable = tableView;
        filteredIndexPaths = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    sourceTable = nil;
    filteredIndexPaths = nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [filteredIndexPaths removeAllObjects];
    
    for (int section = 0; section < [sourceTable.dataSource numberOfSectionsInTableView:sourceTable]; section++) {
        NSMutableArray *filteredSection = [[NSMutableArray alloc] init];
        
        NSString *title = [sourceTable.dataSource tableView:sourceTable titleForHeaderInSection:section];
        for (int row = 0; row < [sourceTable.dataSource tableView:sourceTable numberOfRowsInSection:section]; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            
            if ([title rangeOfString:self.searchDisplayController.searchBar.text options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [filteredSection addObject:indexPath];
            } else {
                UITableViewCell *cell = [sourceTable.dataSource tableView:sourceTable 
                                                    cellForRowAtIndexPath:indexPath];
                UILabel *label = (UILabel *)[cell viewWithTag:2];
                
                if ([label.text rangeOfString:self.searchDisplayController.searchBar.text options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    [filteredSection addObject:indexPath];
                }
            }
        }
        
        if (filteredSection.count > 0) {
            [filteredIndexPaths addObject:filteredSection];
        }
    }
    
    return filteredIndexPaths.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[filteredIndexPaths objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [sourceTable.dataSource tableView:sourceTable 
                                        cellForRowAtIndexPath:[[filteredIndexPaths objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    
    UITableViewCell *copy = [tableView dequeueReusableCellWithIdentifier:@"CopyCell"];
    if (!copy) {
        copy = [[DTTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CopyCell"];
        copy.autoresizingMask = cell.autoresizingMask;
        copy.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    copy.frame = CGRectMake(0, 0, 320, 54);
    [[copy viewWithTag:1] removeFromSuperview];
    [[copy viewWithTag:2] removeFromSuperview];
    copy.indentationLevel = cell.indentationLevel;
    copy.indentationWidth = cell.indentationWidth;

    UIView *icon = [cell viewWithTag:1];
    if ([icon isKindOfClass:[UIImageView class]]) {
        UIImageView *view = [[UIImageView alloc] initWithFrame:icon.frame];
        view.image = [(UIImageView *)icon image];
        view.tag = icon.tag;
        view.autoresizingMask = icon.autoresizingMask;
        [copy addSubview:view];
    } else {
        UIView *view = [icon copy];
        view.tag = icon.tag;
        [copy addSubview:view];
    }
    [copy viewWithTag:1].frame = CGRectMake(10, 
                                            (copy.frame.size.height - icon.frame.size.height) / 2.0, 
                                            icon.frame.size.width, 
                                            icon.frame.size.height);

    
    UILabel *label = (UILabel *)[cell viewWithTag:2];
    UILabel *labelCopy = [[UILabel alloc] initWithFrame:CGRectMake(54, 8, 256, 38)];
    labelCopy.text = label.text;
    labelCopy.numberOfLines = label.numberOfLines;
    labelCopy.font = label.font;
    labelCopy.lineBreakMode = label.lineBreakMode;
    labelCopy.backgroundColor = [UIColor clearColor];
    labelCopy.tag = label.tag;
    labelCopy.autoresizingMask = label.autoresizingMask;
    labelCopy.textColor = label.textColor;
    
    [copy addSubview:labelCopy];

    CGFloat padding = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ? 10 : 45;
    for (int i = 1; i <= 2; i++) {
        UIView *v = [copy viewWithTag:i];
        v.frame = CGRectMake(v.frame.origin.x + padding, v.frame.origin.y, v.frame.size.width, v.frame.size.height);
    }
    
    return copy;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSIndexPath *indexPath = [[filteredIndexPaths objectAtIndex:section] lastObject];
    return [UIView tableHeaderViewWithTitle:[sourceTable.dataSource tableView:sourceTable titleForHeaderInSection:indexPath.section]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSIndexPath *indexPath = [[filteredIndexPaths objectAtIndex:section] lastObject];
    return [sourceTable.delegate tableView:sourceTable heightForHeaderInSection:indexPath.section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *actualPath = [[filteredIndexPaths objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    return [sourceTable.delegate tableView:sourceTable heightForRowAtIndexPath:actualPath];
}

@end
