//
//  DTSettingsParser.h
//  FN3
//
//  Created by David Jablonski on 5/14/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTSettingsParser : NSOperation {
    id response;
    NSString *username;
}

- (id)initWithResponse:(id)response username:(NSString *)username;

@end
