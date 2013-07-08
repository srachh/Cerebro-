//
//  DTPlanField.m
//  FN3
//
//  Created by David Jablonski on 4/30/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTPlanSelectField.h"

#import "DTPersistentStore.h"
#import "DTConfiguration.h"
#import "DTPlan.h"
#import "DTPlanStep.h"

const CGFloat kPlanSelectFieldImageSize = 20.0f;

@implementation DTPlanSelectField

@synthesize delegate;
@synthesize driver;
@synthesize planId, planStep;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plan.png"]];
    imageView.frame = CGRectMake(10, 
                                 (self.frame.size.height - kPlanSelectFieldImageSize) / 2.0, 
                                 kPlanSelectFieldImageSize, 
                                 kPlanSelectFieldImageSize);
    [self addSubview:imageView];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 10, 
                                                      4, 
                                                      self.frame.size.width - imageView.frame.origin.x - imageView.frame.size.width + 20, 
                                                      self.frame.size.height - 8)];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont boldSystemFontOfSize:14];
    label.backgroundColor = [UIColor clearColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:label];
    
    store = [[DTPersistentStore alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(configurationUpdated:) 
                                                 name:DTConfigurationUpdate
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    label = nil;
    imageView = nil;
    store = nil;
    popoverController = nil;
    
    resultsController = nil;
    planId = nil;
    planIdBeforeEditing = nil;
    planStep = nil;
    planStepBeforeEditing = nil;
}

- (DTFieldPermissions)permissions
{
    return DTFieldPermissionEditable | DTFieldPermissionAvailable;
}

- (void)setEditableFields:(NSSet *)editable availableFields:(NSSet *)available {}

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
    UIPickerView *picker = [[UIPickerView alloc] init];
    picker.delegate = self;
    picker.dataSource = self;
    picker.showsSelectionIndicator = YES;
    [picker reloadAllComponents];
    
    [self setSelectedRowsForPickerView:picker];
    
    return picker;
}

- (void)setSelectedRowsForPickerView:(UIPickerView *)pickerView
{
    NSArray *plans = [resultsController.sections.lastObject objects];
    for (int i = 0; i < plans.count; i++) {
        DTPlan *plan = [plans objectAtIndex:i];
        if ([planId isEqualToNumber:plan.identifier]) {
            NSInteger selectedStep = -1;
            if (plan.steps.count > 0) {
                DTPlanStep *step = [plan stepWithValue:planStep];
                selectedStep = step.order.integerValue;
            }
            
            [pickerView selectRow:i inComponent:0 animated:NO];
            [pickerView reloadComponent:1];
            if (selectedStep >= 0) {
                [pickerView selectRow:selectedStep inComponent:1 animated:NO];
            }
            
            break;
        }
    }
}

- (void)setDriver:(NSString *)_driver planId:(NSNumber *)_planId step:(NSString *)_step
{
    driver = _driver;
    planId = _planId;
    planStep = _step;
    
    DTConfiguration *config;
    if (driver && planId) {
        config = [DTConfiguration configurationNamed:driver inContext:store.managedObjectContext];
    }
    
    if (config) {
        DTPlan *plan = [DTPlan configuration:config planById:planId];
        
        if (plan) {
            planId = plan.identifier;
            
            imageView.image = plan.icon;
            label.text = plan.name;
            
            if (plan.steps.count > 0) {
                DTPlanStep *step = [plan stepWithValue:planStep];
                label.text = [NSString stringWithFormat:@"%@ : %@", label.text, step.name];
            }
        } else {
            imageView.image = nil;
            label.text = nil;
            NSLog(@"Plan not found for driver: %@ and plan ID: %@", driver, planId.stringValue);
        }
    } else {
        imageView.image = nil;
        label.text = nil;
    }
}

- (void)loadData
{
    [store.managedObjectContext reset];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[[DTPlan class] description]];
    request.predicate = [NSPredicate predicateWithFormat:@"configuration.name == %@", driver];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                            managedObjectContext:store.managedObjectContext
                                                              sectionNameKeyPath:nil
                                                                       cacheName:nil];
    
    NSError *error;
    [resultsController performFetch:&error];
}

- (void)configurationUpdated:(NSNotification *)notification
{
    if (self.customInputView.superview) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^(void) {
            [self loadData];
            
            UIPickerView *picker = (UIPickerView *)self.customInputView;
            [picker reloadAllComponents];
            [self setSelectedRowsForPickerView:picker];
        }];
    }
}

- (void)beginEditingAnimated:(BOOL)animated
{
    [super beginEditingAnimated:animated];
    
    label.textColor = [UIColor whiteColor];
    
    if (!planIdBeforeEditing) {
        planIdBeforeEditing = planId;
        planStepBeforeEditing = planStep;
    }
}

- (void)revert
{
    [self setDriver:driver planId:planIdBeforeEditing step:planStepBeforeEditing];
}

- (void)endEditingAnimated:(BOOL)animated
{
    [super endEditingAnimated:animated];
    
    label.textColor = [UIColor blackColor];
    
    planIdBeforeEditing = nil;
    planStepBeforeEditing = nil;
}

#pragma mark - Picker view data source methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    [self loadData];
    
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger selectedPlan = [pickerView selectedRowInComponent:0];
    
    id<NSFetchedResultsSectionInfo> section = resultsController.sections.lastObject;
    
    if (component == 0) {
        return [section numberOfObjects];
    } else if ([section numberOfObjects] > 0 && selectedPlan < [section numberOfObjects]) {
        DTPlan *plan = [resultsController objectAtIndexPath:[NSIndexPath indexPathForRow:selectedPlan inSection:0]];
        return plan.steps.count;
    } else {
        return 0;
    }
}

#pragma mark - Picker view delegate methods

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)reuseView
{
    if (component == 0) {
        DTPlan *plan = [resultsController objectAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        
        UIImageView *icon;
        UILabel *title;
        
        if (reuseView) {
            icon = (UIImageView *)[reuseView viewWithTag:1];
            title = (UILabel *)[reuseView viewWithTag:2];
        } else {
            reuseView = [[UIView alloc] initWithFrame:CGRectMake(0, 
                                                                 0, 
                                                                 [self pickerView:pickerView widthForComponent:component],
                                                                 40)];
            
            icon = [[UIImageView alloc] initWithImage:plan.icon];
            icon.frame = CGRectMake(10, 
                                    (reuseView.frame.size.height - kPlanSelectFieldImageSize) / 2.0, 
                                    kPlanSelectFieldImageSize, 
                                    kPlanSelectFieldImageSize);
            icon.tag = 1;
            [reuseView addSubview:icon];
            
            title = [[UILabel alloc] initWithFrame:CGRectMake(icon.frame.origin.x + icon.frame.size.width + 10, 
                                                              0, 
                                                              reuseView.frame.size.width - kPlanSelectFieldImageSize - (icon.frame.origin.x + icon.frame.size.width + 10), 
                                                              reuseView.frame.size.height)];
            title.backgroundColor = [UIColor clearColor];
            title.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            title.tag = 2;
            [reuseView addSubview:title];
        }
        
        icon.image = plan.icon;
        title.text = plan.name;
        
        return reuseView;
    } else {
        NSInteger selectedPlan = [pickerView selectedRowInComponent:0];
        DTPlan *plan = [resultsController objectAtIndexPath:[NSIndexPath indexPathForRow:selectedPlan inSection:0]];
        DTPlanStep *step = [plan.sortedSteps objectAtIndex:row];
        
        UILabel *title;
        if (reuseView) {
            title = (UILabel *)[reuseView viewWithTag:1];
        }
        if (!reuseView) {
            reuseView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                 0,
                                                                 [self pickerView:pickerView widthForComponent:component],
                                                                 40)];
            
            title = [[UILabel alloc] initWithFrame:CGRectMake(8,
                                                              0, 
                                                              reuseView.frame.size.width - 30,
                                                              reuseView.frame.size.height)];
            title.backgroundColor = [UIColor clearColor];
            title.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            title.adjustsFontSizeToFitWidth = YES;
            title.tag = 1;
            
            [reuseView addSubview:title];
        }
        
        title.text = step.name;
        
        return reuseView;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    switch (component) {
        case 0: return pickerView.frame.size.width * .75;
        case 1: return pickerView.frame.size.width * .25;
        default: return 0;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [pickerView reloadComponent:1];
    [pickerView selectRow:[pickerView selectedRowInComponent:1] inComponent:1 animated:NO];
    
    DTPlan *plan = [resultsController objectAtIndexPath:[NSIndexPath indexPathForRow:[pickerView selectedRowInComponent:0]
                                                                           inSection:0]];
    
    label.text = plan.name;
    planId = plan.identifier;
    
    imageView.image = plan.icon;
    
    if (plan.steps.count > 0) {
        DTPlanStep *step = [plan.sortedSteps objectAtIndex:[pickerView selectedRowInComponent:1]];
        
        label.text = [NSString stringWithFormat:@"%@ : %@", label.text, step.name];
        planStep = step.value;
    } else {
        planStep = nil;
    }
    
    [delegate planSelectField:self selectedPlan:plan];
}

@end
