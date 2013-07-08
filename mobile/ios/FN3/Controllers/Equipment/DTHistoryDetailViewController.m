//
//  DTHistoryDetailViewController.m
//  FieldNET
//
//  Created by Loren Davelaar on 8/22/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTHistoryDetailViewController.h"
#import "NSString+DTString.h"

#import "DTPersistentStore.h"
#import "DTView.h"
#import "UIView+DTCustomViews.h"
#import "DTEquipmentHistory.h"

@implementation DTHistoryDetailViewController

@synthesize eventId;
@synthesize headerView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    store = [[DTPersistentStore alloc] init];
    
    [(UITableView *)self.view setBackgroundView:nil];
    
    self.navigationItem.titleView = [UIView equipmentNavigationTitleView];
    
    // set up the header view
    self.headerView.background = [UIView blackGradientShader];
    self.headerView.roundedCorners = DTViewRoundedCornerBottomLeft | DTViewRoundedCornerBottomRight;

    self.navigationItem.rightBarButtonItem = nil;

    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TopBar_Logo.png"]];
    [(UITableView *)self.view setBackgroundView:nil];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Equipment", nil) 
                                                                   style:UIBarButtonItemStyleBordered 
                                                                  target:nil 
                                                                  action:nil];
    [[self navigationItem] setBackBarButtonItem:backButton];

}

- (void)viewDidUnload
{
    store = nil;
    equipmentHistory = nil;
    
    [self setHeaderView:nil];
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadData
{
    equipmentHistory = [DTEquipmentHistory equipmentHistoryWithId:eventId inContext:store.managedObjectContext];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [self loadData];
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 8;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"History Detail", nil);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView tableHeaderViewWithTitle:[self tableView:tableView titleForHeaderInSection:section]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCell"];
        [self configureCell:cell forIndexPath:indexPath];
        return cell;
    }
    
    return nil;
}

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UILabel *label = (UILabel *)[cell viewWithTag:1];
        if (indexPath.row == 0) {
            label.text = NSLocalizedString(@"Timestamp", nil);
        } else if (indexPath.row == 1) {
            label.text = NSLocalizedString(@"Status", nil);
        } else if (indexPath.row == 2) {
            label.text = NSLocalizedString(@"Duration", nil);
        } else if (indexPath.row == 3) {
            label.text = NSLocalizedString(@"Rate", nil);
        } else if (indexPath.row == 4) {
            label.text = NSLocalizedString(@"Plan", nil);
        } else if (indexPath.row == 5) {
            label.text = NSLocalizedString(@"Position", nil);
        } else if (indexPath.row == 6) {
            label.text = NSLocalizedString(@"Accessories On", nil);
        } else if (indexPath.row == 7) {
            label.text = NSLocalizedString(@"Water", nil);
        }
        
        UILabel *value = (UILabel *)[cell viewWithTag:2];
        value.text = [self valueForRow:indexPath.row inSection:indexPath.section];
        
    }
}

- (id)valueForRow:(NSInteger)row inSection:(NSInteger)section
{
    if (section == 0) {
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        format.dateStyle = format.timeStyle = NSDateFormatterShortStyle;
        switch (row) {
            case 0: return [format stringFromDate:equipmentHistory.date];
            case 1: return equipmentHistory.statusSummary;
            case 2: return equipmentHistory.durationDescription;
            case 3: return equipmentHistory.rateDisplay;
            case 4: return equipmentHistory.planDescription;
            case 5: return equipmentHistory.positionDisplay;
            case 6: return equipmentHistory.accessoryDisplay;
            case 7: return equipmentHistory.waterDescription;
        }
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView.dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCell"];
    
    NSString *labelText = [(UILabel *)[cell viewWithTag:1] text];
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    UIFont *labelFont = label.font;
    
    CGSize labelTextSize = [labelText sizeWithFont:labelFont];
    
    NSString *valueText = [(UILabel *)[cell viewWithTag:2] text];
    UILabel *value = (UILabel *)[cell viewWithTag:2];
    UIFont *valueFont = value.font;
    
    CGSize valueTextSize = [valueText sizeWithFont:valueFont];
    
    CGFloat labelHeight = 46;
    CGFloat valueHeight = 46;
    CGFloat cellHeight = 46;
    
    if ((labelTextSize.height > 0) || (valueTextSize.height > 0)) {
        double finalLabelHeight = CGFLOAT_MAX; //self.view.frame.size.height;
        // subtracting 10 from label.frame.size.width because it appears
        // to have padding or margin added in.
        double finalLabelWidth = label.frame.size.width;
        labelHeight = [labelText sizeWithFont:labelFont 
                          constrainedToSize:CGSizeMake(finalLabelWidth, finalLabelHeight) 
                              lineBreakMode:label.lineBreakMode].height;
//        labelHeight = [label sizeThatFits:CGSizeMake(finalLabelWidth, finalLabelHeight)].height;
        
        double finalValueHeight = CGFLOAT_MAX; //self.view.frame.size.height;
        // subtracting 10 from label.frame.size.width because it appears
        // to have padding or margin added in.
        double finalValueWidth = value.frame.size.width;
        valueHeight = [valueText sizeWithFont:valueFont 
                            constrainedToSize:CGSizeMake(finalValueWidth, finalValueHeight) 
                                lineBreakMode:value.lineBreakMode].height;
//        valueHeight = [value sizeThatFits:CGSizeMake(finalValueWidth, finalValueHeight)].height;
        
        if (labelHeight > valueHeight) {
            NSLog(@"%@: label height value being used: %f\n", labelText, labelHeight);
            cellHeight = labelHeight;
        } else if (labelHeight < valueHeight) {
            NSLog(@"%@: value height value being used: %f\n", labelText, valueHeight);
            cellHeight = valueHeight;
        } else if ((labelHeight + 20) > cellHeight) {
            NSLog(@"%@: heights are same, defaulting to label height: %f\n", labelText, labelHeight);
            cellHeight = labelHeight;
        }
        
        if (cellHeight != 46) {
            // add the padding
            cellHeight += 20;
        }
    }
    
    NSLog(@"%@: cellHeight before return: %f\n", labelText, cellHeight);
    
    return cellHeight < 46 ? 46 : cellHeight;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
