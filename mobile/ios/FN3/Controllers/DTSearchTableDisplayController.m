//
//  DTSearchDisplayController.m
//  FN3
//
//  Created by David Jablonski on 3/26/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTSearchTableDisplayController.h"
#import "NSString+DTString.h"

@implementation DTSearchTableDisplayController

@synthesize contentController;
@synthesize tableViewDataSource, tableViewDelegate;
@synthesize searchBar;
@synthesize isSearching;
@synthesize showsCancelButton;
@synthesize tableViewStyle;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.showsCancelButton = YES;
    self.tableViewStyle = UITableViewStyleGrouped;
}

- (void)dealloc
{
    tableView = nil;
    dimView = nil;
    self.tableViewDelegate = nil;
    self.tableViewDataSource = nil;
    self.searchBar = nil;
}

- (UITableView *)searchResultsTableView
{
    if (!tableView) {
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)
                                                 style:UITableViewStyleGrouped];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.delegate = self.tableViewDelegate ? self.tableViewDelegate : self.contentController;
        tableView.dataSource = self.tableViewDataSource ? self.tableViewDataSource : self.contentController;
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login.jpg"]];
        tableView.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return tableView;
}

- (void)setSearchBar:(UISearchBar *)_searchBar
{
    searchBar = _searchBar;
    searchBar.delegate = self;
}

- (void)hideSearchBar
{
    if (self.searchResultsTableView.superview) {
        [self.searchBar resignFirstResponder];
    } else {
        [self searchBarCancelButtonClicked:self.searchBar];
    }
}

#pragma mark - Search bar delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    UIView *parent = self.searchBar.superview;
    CGRect dimFrame = CGRectMake(parent.frame.origin.x, 
                                 self.searchBar.frame.size.height + self.searchBar.frame.origin.y, 
                                 parent.frame.size.width, 
                                 parent.frame.size.height - self.searchBar.frame.size.height - self.searchBar.frame.origin.y);
    
    if (!dimView) {
        dimView = [[UIView alloc] initWithFrame:dimFrame];
        dimView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSearchBar)];
        [dimView addGestureRecognizer:tap];
        
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = UITextAlignmentCenter;
        label.frame = CGRectMake(20, 
                                 20, 
                                 parent.frame.size.width - 40, 
                                 50);
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        label.tag = 100000;
        [dimView addSubview:label];
    } else {
        dimView.frame = dimFrame;
    }
    dimView.backgroundColor = [UIColor clearColor];
    [(UILabel *)[dimView viewWithTag:100000] setText:nil];
    [parent addSubview:dimView];
    
    if (!isSearching) {
        [UIView animateWithDuration:0.3 
                         animations:^(void){
                             dimView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
                         }];
        
        if ([parent isKindOfClass:[UIScrollView class]]) {
            [(UIScrollView *)parent setContentOffset:CGPointMake(0,0) animated:NO];
            [(UIScrollView *)parent setScrollEnabled:NO];
        }
        
        [self.searchBar setShowsCancelButton:self.showsCancelButton animated:YES];
        
        isSearching = YES;
    } else if ([self.searchBar.text isBlank]) {
        // this can happen when the clear button on the search field causes the
        // searchbar to begin editing
        dimView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    }
    
    // hide the navigation bar while typing
    [[self.contentController navigationController] setNavigationBarHidden:YES animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (!searchText || [searchText isBlank]) {
        [self.searchResultsTableView removeFromSuperview];
        [self.searchBar.superview addSubview:dimView];
        
        dimView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        [(UILabel *)[dimView viewWithTag:100000] setText:nil];
    } else {
        [self.searchResultsTableView reloadData];
        
        if ([self.searchResultsTableView.dataSource tableView:self.searchResultsTableView numberOfRowsInSection:0] == 0) {
            [self.searchResultsTableView removeFromSuperview];
            
            dimView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
            [(UILabel *)[dimView viewWithTag:100000] setText:NSLocalizedString(@"No Results", nil)];
        } else {
            if (!self.searchResultsTableView.superview) {
                CGFloat searchBarHeight = self.searchBar.frame.size.height;
                self.searchResultsTableView.frame = CGRectMake(0, 
                                                               searchBarHeight, 
                                                               self.searchBar.superview.frame.size.width, 
                                                               self.searchBar.superview.frame.size.height - searchBarHeight);
                [self.searchBar.superview addSubview:self.searchResultsTableView];
                [dimView.superview bringSubviewToFront:dimView];
            }
            
            dimView.backgroundColor = [UIColor clearColor];
            [(UILabel *)[dimView viewWithTag:100000] setText:nil];
        }
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [dimView removeFromSuperview];
    [[self.contentController navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    if (isSearching) {
        [self.searchBar resignFirstResponder];
        
        if (dimView.superview) {
            [UIView animateWithDuration:0.3 
                             animations:^(void) {
                                 dimView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
                             } 
                             completion:^(BOOL finished) {
                                 if (finished) {
                                     [dimView removeFromSuperview];
                                     dimView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
                                 }
                             }];
        }
        [self.searchResultsTableView removeFromSuperview];
        
        
        [self.searchBar setShowsCancelButton:!self.showsCancelButton animated:YES];
        
        if ([self.searchBar.superview isKindOfClass:[UIScrollView class]]) {
            [(UIScrollView *)self.searchBar.superview setScrollEnabled:YES];
        }
        
        [[self.contentController navigationController] setNavigationBarHidden:NO animated:YES];    
        
        isSearching = NO;
    }
    
    self.searchBar.text = nil;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
    [self.searchBar resignFirstResponder];
    if (!self.searchResultsTableView.superview) {
        [self searchBarCancelButtonClicked:_searchBar];
    }
}

@end
