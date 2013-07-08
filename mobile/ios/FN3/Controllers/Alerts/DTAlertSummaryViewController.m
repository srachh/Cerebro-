//
//  DTSecondViewController.m
//  FN3
//
//  Created by David Jablonski on 2/21/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTAlertSummaryViewController.h"

#import "NSString+DTString.h"
#import "DTSearchTableDisplayController.h"
#import "DTEquipmentAlertsViewController.h"

#import "DTPersistentStore.h"
#import "DTEquipmentGroup.h"
#import "DTEquipment.h"
#import "DTAlert.h"

#import "NSOperationQueue+DTOperationQueue.h"
#import "DTConnection.h"
#import "DTResponse.h"
#import "DTAlertsParser.h"

#import "DTAnalytics.h"

@implementation DTAlertSummaryViewController

@synthesize group;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [(UITableView *)self.view setBackgroundView:nil];
    
    store = [[DTPersistentStore alloc] init];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Alerts", nil)
                                                                   style:UIBarButtonItemStyleBordered 
                                                                  target:nil 
                                                                  action:nil];
    [[self navigationItem] setBackBarButtonItem:backButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(alertsUpdated:) 
                                                 name:DTAlertUpdate 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(alertsUpdated:) 
                                                 name:DTEquipmentDelete
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(alertStatusUpdated:) 
                                                 name:DTEquipmentAlertStatusUpdate 
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [refreshTimer invalidate];
    if (self.navigationController) {
        refreshTimer = [NSTimer scheduledTimerWithTimeInterval:15 
                                                        target:self 
                                                      selector:@selector(refreshData) 
                                                      userInfo:nil 
                                                       repeats:YES];
        isRunningRefresh = NO;
        [refreshTimer fire];
    }
    
    [[DTAnalytics instance] trackViewController:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [refreshTimer invalidate];
    refreshTimer = nil;
    
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.group = nil;
    
    sortedSections = nil;
    sortedSearchSections = nil;
    
    resultsController = nil;
    searchResultsController = nil;
    store = nil;
    
    searchController = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

- (void)refreshData
{
    if (!isRunningRefresh) {
        [[NSOperationQueue networkQueue] addNetworkOperationWithBlock:^(void){
            isRunningRefresh = YES;
            
            DTResponse *response = [DTConnection getTo:FN3APIAlerts parameters:nil];
            if (response.isSuccess) {
                NSOperation *op = [[DTAlertsParser alloc] initWithResponse:response.data];
                op.completionBlock = ^(void){
                    isRunningRefresh = NO;
                };
                [[NSOperationQueue parserQueue] addOperation:op];
            } else {
                isRunningRefresh = NO;
            }
        }];
    }
}

- (void)alertsUpdated:(NSNotification *)notification
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
        [(UITableView *)self.view reloadData];
    }];
}

- (void)alertStatusUpdated:(NSNotification *)notification
{
/*
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void) {
        NSNumber *equipmentId = notification.object;
        
        for (int i = 0; i < alerts.count; i++) {
            DTAlertSummary *alert = [alerts objectAtIndex:i];
            if ([alert.equipmentIdentifier isEqualToNumber:equipmentId]) {
                alert.hasUnviewed = NO;
                UITableViewCell *cell = [(UITableView *)self.view cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                UIImageView *icon = (UIImageView *)[cell viewWithTag:1];
                icon.image = [UIImage imageNamed:@"gray_light.png"];
                
                break;
            }
        }
        
        if (searchController.searchResultsTableView.superview) {
            for (int i = 0; i < filteredAlerts.count; i++) {
                DTAlertSummary *alert = [filteredAlerts objectAtIndex:i];
                if ([alert.equipmentIdentifier isEqualToNumber:equipmentId]) {
                    alert.hasUnviewed = NO;
                    UITableViewCell *cell = [(UITableView *)self.view cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                    UIImageView *icon = (UIImageView *)[cell viewWithTag:1];
                    icon.image = [UIImage imageNamed:@"gray_light.png"];
                    
                    break;
                }
            }
        }
    }];
*/
}

- (void)loadDataForTableView:(UITableView *)tableView
{
    if (tableView == self.view) {
        sortedSearchSections = nil;
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:[[DTAlert class] description]
                                     inManagedObjectContext:store.managedObjectContext];
        
        if (group) {
            request.predicate = [NSPredicate predicateWithFormat:@"equipment.groups CONTAINS %@", group];
        }
        
        request.sortDescriptors = [NSArray arrayWithObjects:
                                   [NSSortDescriptor sortDescriptorWithKey:@"equipment.title"
                                                                 ascending:YES
                                                                  selector:@selector(caseInsensitiveCompare:)],
                                   [NSSortDescriptor sortDescriptorWithKey:@"date"ascending:NO],
                                   nil];
        resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                managedObjectContext:store.managedObjectContext
                                                                  sectionNameKeyPath:@"equipment.title"
                                                                           cacheName:nil];
        NSError *error;
        [resultsController performFetch:&error];
        
        sortedSections = [resultsController.sections sortedArrayUsingComparator:^NSComparisonResult(id<NSFetchedResultsSectionInfo> s1, id<NSFetchedResultsSectionInfo> s2){
            DTAlert *a1 = [[s1 objects] objectAtIndex:0];
            DTAlert *a2 = [[s2 objects] objectAtIndex:0];
            return [a2.date compare:a1.date];
        }];
    } else {
        sortedSections = nil;
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:[[DTAlert class] description]
                                     inManagedObjectContext:store.managedObjectContext];
        
        NSMutableArray *predicates = [[NSMutableArray alloc] initWithCapacity:2];
        if (group) {
            [predicates addObject:[NSPredicate predicateWithFormat:@"equipment.groups CONTAINS %@", group]];
        }
        [predicates addObject:[NSPredicate predicateWithFormat:@"equipment.title CONTAINS[c] %@ or ANY equipment.groups.name CONTAINS[c] %@", searchController.searchBar.text, searchController.searchBar.text]];
        request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
        
        request.sortDescriptors = [NSArray arrayWithObjects:
                                   [NSSortDescriptor sortDescriptorWithKey:@"equipment.title"
                                                                 ascending:YES
                                                                  selector:@selector(caseInsensitiveCompare:)],
                                   [NSSortDescriptor sortDescriptorWithKey:@"date"ascending:NO],
                                   nil];
        
        searchResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                      managedObjectContext:store.managedObjectContext
                                                                        sectionNameKeyPath:@"equipment.title"
                                                                                 cacheName:nil];
        NSError *error;
        [searchResultsController performFetch:&error];
        
        sortedSearchSections = [searchResultsController.sections sortedArrayUsingComparator:^NSComparisonResult(id<NSFetchedResultsSectionInfo> s1, id<NSFetchedResultsSectionInfo> s2){
            DTAlert *a1 = [[s1 objects] objectAtIndex:0];
            DTAlert *a2 = [[s2 objects] objectAtIndex:0];
            return [a2.date compare:a1.date];
        }];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [store.managedObjectContext reset];
    [self loadDataForTableView:tableView];
    
    
    if (tableView == self.view && [resultsController.sections count]!=0) {
        id<NSFetchedResultsSectionInfo> section = [resultsController.sections objectAtIndex:0];
        if ([section objects].count == 0) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
            label.text = NSLocalizedString(@"No alerts were found.", nil);
            label.textColor = [UIColor whiteColor];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = UITextAlignmentCenter;
            [(UITableView *)self.view setTableHeaderView:label];
        } else {
            [(UITableView *)self.view setTableHeaderView:searchController.searchBar];
        }
        
        return 1;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.view) {
        return resultsController.sections.count;
    } else {
        return searchResultsController.sections.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [(UITableView *)self.view dequeueReusableCellWithIdentifier:@"AlertCell"];

    NSArray  *sections = tableView == self.view ? sortedSections : sortedSearchSections;
    id<NSFetchedResultsSectionInfo> section = [sections objectAtIndex:indexPath.row];
    DTAlert *alert = [[section objects] objectAtIndex:0];
    
    BOOL hasUnviewed = NO;
    for (DTAlert *alert in [section objects]) {
        if (!alert.viewed.boolValue) {
            hasUnviewed = YES;
            break;
        }
    }
    
    UIImageView *icon = (UIImageView *)[cell viewWithTag:1];
    icon.image = hasUnviewed ? [UIImage imageNamed:@"blue_light.png"] : [UIImage imageNamed:@"gray_light.png"];
    
    UILabel *title = (UILabel *)[cell viewWithTag:2];
    title.text = alert.equipment.title;
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateStyle = format.timeStyle = NSDateFormatterShortStyle;
    [(UILabel *)[cell viewWithTag:3] setText:[format stringFromDate:alert.date]];
    
    UILabel *count = (UILabel *)[cell viewWithTag:4];
    if ([section numberOfObjects] == 1) {
        count.hidden = YES;
    } else {
        count.hidden = NO;
        count.text = [NSString stringWithFormat:@"%i", [section numberOfObjects]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([@"segueToEquipmentAlertsScene" isEqualToString:segue.identifier]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        NSArray  *sections;
        if (searchController.searchResultsTableView.superview) {
            sections = sortedSearchSections;
        } else {
            sections = sortedSections;
        }
        id<NSFetchedResultsSectionInfo> section = [sections objectAtIndex:indexPath.row];
        DTAlert *alert = [[section objects] objectAtIndex:0];
        
        [(DTEquipmentAlertsViewController *)segue.destinationViewController setEquipmentId:alert.equipment.identifier];
    }
}

@end
