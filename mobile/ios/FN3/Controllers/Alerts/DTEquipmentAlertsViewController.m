//
//  DTEquipmentAlertsViewController.m
//  FN3
//
//  Created by David Jablonski on 4/9/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTEquipmentAlertsViewController.h"

#import "DTPersistentStore.h"
#import "DTEquipment.h"
#import "DTAlert.h"

#import "DTAnalytics.h"

@implementation DTEquipmentAlertsViewController

@synthesize equipmentId;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [(UITableView *)self.view setBackgroundView:nil];
    
    unviewedAlertIds = [[NSMutableSet alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(alertsUpdated:) 
                                                 name:DTAlertUpdate 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(equipmentDeleted:) 
                                                 name:DTEquipmentDelete
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[DTAnalytics instance] trackViewController:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.equipmentId = nil;
    resultsController = nil;
    unviewedAlertIds = nil;
    labelFont = nil;
    
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

- (void)alertsUpdated:(NSNotification *)notification
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
        DTPersistentStore *store = [[DTPersistentStore alloc] init];
        DTEquipment *equipment = [DTEquipment equipmentWithId:equipmentId inContext:store.managedObjectContext];
        if (equipment.alerts.count == 0) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [(UITableView *)self.view reloadData];
        }
    }];
}
- (void)equipmentDeleted:(NSNotification *)notification {
    if ([notification.object containsObject:equipmentId]) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^(void) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}

#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    DTPersistentStore *store = [[DTPersistentStore alloc] init];
    
    DTEquipment *equipment = [DTEquipment equipmentWithId:equipmentId inContext:store.managedObjectContext];
    self.title = equipment.title;
    
    BOOL statusesChanged = NO;
    for (DTAlert *alert in equipment.alerts) {
        if (![alert.viewed boolValue]) {
            [unviewedAlertIds addObject:alert.identifier];
            
            alert.viewed = [NSNumber numberWithBool:YES];
            statusesChanged = YES;
        }
    }
    if (statusesChanged) {
        [store save];
        [[NSNotificationCenter defaultCenter] postNotificationName:DTEquipmentAlertStatusUpdate 
                                                            object:equipment.identifier];
    }
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[[DTAlert class] description]];
    request.predicate = [NSPredicate predicateWithFormat:@"equipment = %@", equipment];
    request.sortDescriptors = [NSArray arrayWithObjects:
                               [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO], 
                               [NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:NO], 
                               nil];
    
    resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request 
                                                            managedObjectContext:store.managedObjectContext 
                                                              sectionNameKeyPath:nil 
                                                                       cacheName:nil];
    NSError *error;
    [resultsController performFetch:&error];
    
    if (resultsController.sections.count == 0) {
        return 0;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionNumber
{
    id<NSFetchedResultsSectionInfo> section = [resultsController.sections objectAtIndex:sectionNumber];
    return [section numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"AlertMessageCell"];
    UIImageView *image = (UIImageView *)[cell viewWithTag:1];
    UILabel *label = (UILabel *)[cell viewWithTag:2];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:3];
    
    id<NSFetchedResultsSectionInfo> section = [resultsController.sections objectAtIndex:indexPath.section];
    DTAlert *alert = [[section objects] objectAtIndex:indexPath.row];
    
    if ([unviewedAlertIds containsObject:alert.identifier]) {
        image.image = [UIImage imageNamed:@"blue_light.png"];
    } else {
        image.image = [UIImage imageNamed:@"gray_light.png"];
    }
    
    label.text = alert.message;
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateStyle = format.timeStyle = NSDateFormatterShortStyle;
    dateLabel.text = [format stringFromDate:alert.date];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<NSFetchedResultsSectionInfo> section = [resultsController.sections objectAtIndex:indexPath.section];
    DTAlert *alert = [[section objects] objectAtIndex:indexPath.row];
    
    NSString *cellText = alert.message;
    
    if (!labelFont) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlertMessageCell"];
        UILabel *label = (UILabel *)[cell viewWithTag:2];
        labelFont = label.font;
        labelFrame = label.frame;
        labelLineBreakMode = label.lineBreakMode;
    }
    
    CGFloat cellHeight = 62;
    CGSize textSize = [cellText sizeWithFont:labelFont];
    if (textSize.height > 0) {
        double finalHeight = self.view.frame.size.height;
        double finalWidth = labelFrame.size.width;
        CGFloat height = [cellText sizeWithFont:labelFont constrainedToSize:CGSizeMake(finalWidth, finalHeight) lineBreakMode:labelLineBreakMode].height;
        // add the padding
        cellHeight += height - labelFrame.size.height;
    }
    
    return cellHeight;
}

@end
