//
//  DTEquipmentGroupViewController.m
//  FN3
//
//  Created by David Jablonski on 3/7/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTEquipmentGroupViewController.h"
#import "UIViewController+DTViewController.h"

#import "DTTableViewCell.h"
#import "DTEquipmentGroup.h"
#import "DTPersistentStore.h"

#import "DTAnalytics.h"

@implementation DTEquipmentGroupViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    store = [[DTPersistentStore alloc] init];
    

    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TopBar_Logo.png"]];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Groups", nil)
                                                                             style:UIBarButtonItemStyleBordered 
                                                                            target:nil 
                                                                            action:nil];
    
    
    [(UITableView *)self.view setBackgroundView:nil];
    
    isExpired = YES;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(equipmentGroupUpdate:) 
                                                 name:DTEquipmentGroupUpdate 
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (isExpired) {
        [(UITableView *)self.view reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[DTAnalytics instance] trackViewController:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
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

#pragma mark - Table view data source

- (void)loadData
{
    if (isExpired) {
        NSLog(@"loading equipment group data");
        
        [store.managedObjectContext reset];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:[[DTEquipmentGroup class] description] 
                                     inManagedObjectContext:store.managedObjectContext];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                managedObjectContext:store.managedObjectContext 
                                                                  sectionNameKeyPath:nil 
                                                                           cacheName:nil];
        NSError *error;
        [resultsController performFetch:&error];
        
        isExpired = NO;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [self loadData];
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (resultsController.sections.count == 0) {
        return 1;
    } else {
        id <NSFetchedResultsSectionInfo> sectionInfo = [resultsController.sections objectAtIndex:section];
        return [sectionInfo numberOfObjects] + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EquipmentGroupCell"];
    if (!cell) {
        cell = [[DTTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                      reuseIdentifier:@"EquipmentGroupCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"All Equipment", nil);
    } else {
        NSIndexPath *groupPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
        DTEquipmentGroup *group = [resultsController objectAtIndexPath:groupPath];
        [resultsController.managedObjectContext refreshObject:group mergeChanges:YES];
        cell.textLabel.text = group.name;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"SegueToRootScene" 
                              sender:[tableView cellForRowAtIndexPath:indexPath]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UITableViewCell *cell = sender;
    NSIndexPath *indexPath = [(UITableView *)self.view indexPathForCell:cell];
    UIViewController *controller = segue.destinationViewController;
    
    if (indexPath.row == 0) {
        controller.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TopBar_Logo.png"]];
        [controller setValue:nil forKey:@"group"];
    } else {
        NSIndexPath *groupPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
        DTEquipmentGroup *group = [resultsController objectAtIndexPath:groupPath];
        
        controller.navigationItem.titleView = nil;
        controller.title = group.name;
        [controller setValue:group forKey:@"group"];
    }
}

#pragma mark - Notifications

- (void)equipmentGroupUpdate:(NSNotification *)notification
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
        isExpired = YES;
        if ([self isCurrentlyDisplayed]) {
            [(UITableView *)self.view reloadData];
        }
    }];
}

@end
