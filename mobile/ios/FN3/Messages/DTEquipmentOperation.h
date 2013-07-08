//
//  DTEquipmentRefreshOperation.h
//  FN3
//
//  Created by David Jablonski on 5/3/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTEquipmentOperation : NSOperation {
    NSNumber *equipmentId;
}

- (id)initWithEquipmentId:(NSNumber *)equipmentId;

@end
