//
//  DTEquipmentListViewController.m
//  FN3
//
//  Created by David Jablonski on 3/5/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTEquipmentListViewController.h"
#import "UIViewController+DTViewController.h"
#import "DTSearchTableDisplayController.h"

#import "NSOperationQueue+DTOperationQueue.h"
#import "DTConnection.h"
#import "DTResponse.h"
#import "DTEquipmentParser.h"

#import "DTEquipmentView.h"
#import "DTPivotView.h"
#import "DTLateralView.h"
#import "DTPumpView.h"
#import "UIColor+DTColor.h"
#import "DTDashboardViewController.h"

#import "DTPersistentStore.h"
#import "DTEquipmentGroup.h"
#import "DTEquipment.h"
#import "DTPivot.h"
#import "DTPumpStation.h"
#import "DTLateral.h"
#import "DTGeneralIO.h"

#import "DTAnalytics.h"


@implementation DTEquipmentListViewController

@synthesize group;


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [(UITableView *)self.view setBackgroundView:nil];
    
    store = [[DTPersistentStore alloc] init];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(equipmentListUpdate:) 
                                                 name:DTEquipmentUpdate
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(equipmentDetailUpdate:) 
                                                 name:DTEquipmentDetailUpdate
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    resultsController = searchResultsController = nil;
    
    [super viewDidUnload];
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
            
            DTResponse *groupsResponse = [DTConnection getTo:FN3APIGroupList parameters:nil];
            if (groupsResponse.isSuccess) {
                DTResponse *listResponse = [DTConnection postTo:FN3APIEquipmentList parameters:nil];
                if (listResponse.isSuccess) {
                    NSOperation *op = [[DTEquipmentParser alloc] initWithGroupsResponse:groupsResponse.data
                                                                           listResponse:listResponse.data];
                    op.completionBlock = ^(void){
                        isRunningRefresh = NO;
                    };
                    [[NSOperationQueue parserQueue] addOperation:op];
                } else {
                    isRunningRefresh = NO;
                }
            } else {
                isRunningRefresh = NO;
            }
        }];
    }
}

#pragma mark - Table view data source

- (void)loadDataForTableView:(UITableView *)tableView
{
    if (tableView == self.view) {
        NSLog(@"loading equipment list data");
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:[[DTEquipment class] description] 
                                     inManagedObjectContext:store.managedObjectContext];
        
        if (group) {
            request.predicate = [NSPredicate predicateWithFormat:@"groups CONTAINS %@", group];
        }
        
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" 
                                                                                         ascending:YES 
                                                                                          selector:@selector(caseInsensitiveCompare:)]];
        resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                managedObjectContext:store.managedObjectContext 
                                                                  sectionNameKeyPath:nil 
                                                                           cacheName:nil];
        NSError *error;
        [resultsController performFetch:&error];
        
    } else {
        NSLog(@"loading equipment search data");
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:[[DTEquipment class] description] 
                                     inManagedObjectContext:store.managedObjectContext];
        
        NSMutableArray *predicates = [[NSMutableArray alloc] initWithCapacity:2];
        if (group) {
            [predicates addObject:[NSPredicate predicateWithFormat:@"groups CONTAINS %@", group]];
        }
        [predicates addObject:[NSPredicate predicateWithFormat:@"title CONTAINS[c] %@ or ANY groups.name CONTAINS[c] %@", searchBarDisplayController.searchBar.text, searchBarDisplayController.searchBar.text]];
        request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
        
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" 
                                                                                         ascending:YES 
                                                                                          selector:@selector(caseInsensitiveCompare:)]];
        searchResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                managedObjectContext:store.managedObjectContext 
                                                                  sectionNameKeyPath:nil 
                                                                           cacheName:nil];
        NSError *error;
        [searchResultsController performFetch:&error];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [self loadDataForTableView:tableView];
    
    if (tableView == self.view) {
        id<NSFetchedResultsSectionInfo> section = [resultsController.sections objectAtIndex:0];
        if ([section objects].count == 0) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
            label.text = NSLocalizedString(@"No devices were found.", nil);
            label.textColor = [UIColor whiteColor];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = UITextAlignmentCenter;
            [(UITableView *)self.view setTableHeaderView:label];
        } else {
            [(UITableView *)self.view setTableHeaderView:searchBarDisplayController.searchBar];
        }
        
        return resultsController.sections.count;
    } else {
        return searchResultsController.sections.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.view) {
        id<NSFetchedResultsSectionInfo> s = [resultsController.sections objectAtIndex:section];
        return [s numberOfObjects];
    } else {
        id<NSFetchedResultsSectionInfo> s = [searchResultsController.sections objectAtIndex:section];
        return [s numberOfObjects];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSFetchedResultsController *rc = tableView == self.view ? resultsController : searchResultsController;
    DTEquipment *equipment = [rc objectAtIndexPath:indexPath];
    UITableViewCell *cell = [(UITableView *)self.view dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%@Cell", [[equipment class] description]]];
    
    [self setCell:cell fromEquipment:equipment];
    
    return cell;
}

- (void)setCell:(UITableViewCell *)cell fromEquipment:(DTEquipment *)equipment
{
    if ([equipment isKindOfClass:[DTGeneralIO class]]) {
        DTGeneralIO *io = (DTGeneralIO *)equipment;
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
        imageView.image = io.icon;
    } else {
        id<DTEquipmentView> equipmentView = (id<DTEquipmentView>)[cell viewWithTag:1];
        [equipmentView configureFromEquipment:equipment];
        equipmentView.detailLevel = DTEquipmentDetailLevelList;
    }
    
    UILabel *title = (UILabel *)[cell viewWithTag:2];
    title.text = equipment.title;
    
    UILabel *summary = (UILabel *)[cell viewWithTag:3];
    summary.text = equipment.subtitle;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UITableViewCell *cell = sender;
    DTEquipment *equipment;
    if (searchBarDisplayController.searchResultsTableView.superview) {
        NSIndexPath *indexPath = [searchBarDisplayController.searchResultsTableView indexPathForCell:cell];
        equipment = [searchResultsController objectAtIndexPath:indexPath];
    } else {
        NSIndexPath *indexPath = [(UITableView *)self.view indexPathForCell:cell];
        equipment = [resultsController objectAtIndexPath:indexPath];
    }
    
    id<DTDashboardViewController> controller = segue.destinationViewController;
    controller.equipmentId = equipment.identifier;
}

#pragma mark - Notifications

- (void)equipmentListUpdate:(NSNotification *)notification
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
        [store.managedObjectContext reset]; 
        
        [(UITableView *)self.view reloadData];
        
        if (searchBarDisplayController.searchResultsTableView.superview) {
            [searchBarDisplayController.searchResultsTableView reloadData];
        }
    }];
}

- (void)equipmentDetailUpdate:(NSNotification *)notification
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
        for (NSNumber *equipmentId in notification.object) {
            DTEquipment *equipment = [DTEquipment equipmentWithId:equipmentId
                                                        inContext:store.managedObjectContext];
            NSIndexPath *indexPath = [resultsController indexPathForObject:equipment];
            [store.managedObjectContext refreshObject:equipment mergeChanges:YES];
            
            UITableViewCell *cell = [(UITableView *)self.view cellForRowAtIndexPath:indexPath];
            if (cell) {
                [self setCell:cell fromEquipment:equipment];
            }
        }
    }];
}

@end
