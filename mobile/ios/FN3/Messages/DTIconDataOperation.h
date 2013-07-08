//
//  DTIconDataOperation.h
//  FN3
//
//  Created by David Jablonski on 5/29/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTIconDataOperation : NSOperation {
    NSSet *imagePaths;
    NSNotification *notification;
}

- (id)initWithImagePaths:(NSSet *)imagePaths notification:(NSNotification *)notification;

@end
