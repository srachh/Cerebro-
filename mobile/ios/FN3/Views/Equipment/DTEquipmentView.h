//
//  DTEquipmentView.h
//  FN3
//
//  Created by David Jablonski on 3/23/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTEquipment.h"


enum {
    DTEquipmentDetailLevelList     = 0,
    DTEquipmentDetailLevelDetail   = 1,
    DTEquipmentDetailLevelMap      = 2
};
typedef NSUInteger DTEquipmentDetailLevel;


@protocol DTEquipmentView <NSObject>

- (void)configureFromEquipment:(DTEquipment *)equipment;
@property (nonatomic) DTEquipmentDetailLevel detailLevel;

@end
