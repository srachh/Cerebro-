//
//  DTAlertsParser.h
//  FN3
//
//  Created by David Jablonski on 5/14/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTAlertsParser : NSOperation {
    id response;
}

- (id)initWithResponse:(id)response;

@end
