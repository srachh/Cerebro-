//
//  DTHelpSearchDataSource.h
//  FN3
//
//  Created by David Jablonski on 5/23/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DTSearchTableDisplayController;

@interface DTHelpSearchDataSource : NSObject <UITableViewDataSource, UITableViewDelegate> {
    UITableView *sourceTable;
    
    NSMutableArray *filteredIndexPaths;
}

- (id)initWithTableView:(UITableView *)tableView;

@property (nonatomic, retain) DTSearchTableDisplayController *searchDisplayController;

@end
