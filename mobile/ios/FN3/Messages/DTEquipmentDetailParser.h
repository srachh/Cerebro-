//
//  DTEquipmentDetailParser.h
//  FN3
//
//  Created by David Jablonski on 5/15/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTEquipmentDetailParser : NSOperation {
    id response;
}

- (id)initWithResponse:(id)response;

@end
