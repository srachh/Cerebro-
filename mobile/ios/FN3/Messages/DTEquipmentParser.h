//
//  DTEquipmentParser.h
//  FN3
//
//  Created by David Jablonski on 5/14/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTEquipmentParser : NSOperation {
    id groupsResponse;
    id listResponse;
}

- (id)initWithGroupsResponse:(id)groupsResponse listResponse:(id)listResponse;

@end
