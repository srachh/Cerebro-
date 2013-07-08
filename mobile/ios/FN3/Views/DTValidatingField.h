//
//  DTEditableField.h
//  FieldNET
//
//  Created by Loren Davelaar on 11/2/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DTValidatingField <NSObject>
-(BOOL)validate;
-(BOOL)isValidValue;
@end
