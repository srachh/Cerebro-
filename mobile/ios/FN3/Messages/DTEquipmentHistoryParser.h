//
//  DTEquipmentHistoryParser.h
//  FieldNET
//
//  Created by Loren Davelaar on 8/15/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTEquipmentHistoryParser : NSOperation {
    id listResponse;
    NSInteger startIndex;
}

- (id)initWithListResponse:(NSArray *)listResponse startIndex: (NSInteger)startIndex;

@end
