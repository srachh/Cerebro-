//
//  DTSearchDisplayController.h
//  FN3
//
//  Created by David Jablonski on 3/26/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTSearchTableDisplayController : NSObject <UISearchBarDelegate> {
    UITableView *tableView;
    UIView *dimView;
    
    BOOL isSearching;
}
@property (strong, nonatomic) IBOutlet id contentController;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, readonly) UITableView *searchResultsTableView;
@property (nonatomic, readonly) BOOL isSearching;

@property (nonatomic, retain) id<UITableViewDelegate> tableViewDelegate;
@property (nonatomic, retain) id<UITableViewDataSource> tableViewDataSource;

@property (nonatomic) BOOL showsCancelButton;
@property (nonatomic) UITableViewStyle tableViewStyle;

@end
