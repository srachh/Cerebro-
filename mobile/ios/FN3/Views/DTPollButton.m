//
//  DTPollButton.m
//  FN3
//
//  Created by David Jablonski on 5/3/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTPollButton.h"
#import "DTAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "DTFunctions.h"

#import "UIView+DTCustomViews.h"
#import "UIAlertView+DTAlertView.h"
#import "DTLinearGradientShader.h"
#import "DTSolidShader.h"

#import "NSOperationQueue+DTOperationQueue.h"
#import "DTConnection.h"
#import "DTResponse.h"

#define SPIN_CLOCK_WISE 1
#define SPIN_COUNTERCLOCK_WISE -1

@implementation DTPollButton

@synthesize isInPollError;

- (void)awakeFromNib
{
    [super awakeFromNib];
  
    self.backgroundColor = [UIColor clearColor];
    disabledShader = [[DTSolidShader alloc] initWithColor:[UIColor clearColor]];
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(rect.origin.x, rect.origin.y)];
    [path addLineToPoint:CGPointMake(rect.origin.x + rect.size.width, rect.origin.y)];
    [path addArcWithCenter:CGPointMake(rect.origin.x + rect.size.width - 10.0, rect.origin.y + rect.size.height - 10.0) 
                    radius:10.0 
                startAngle:DTRadiansFromDegrees(0) 
                  endAngle:DTRadiansFromDegrees(90) 
                 clockwise:YES];
    [path addLineToPoint:CGPointMake(rect.origin.x, rect.origin.y + rect.size.height)];
    [path addClip];
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (self.state == UIControlStateHighlighted) {
        [[UIView greenButtonShader] drawInContext:context rect:rect];
    } else if (self.state == UIControlStateDisabled) {
        [disabledShader drawInContext:context rect:rect];
    } else {
        [[UIView greenButtonShader] drawInContext:context rect:rect];
    }
}

- (void)setPollCompleteTarget:(id)target selector:(SEL)selector
{
    NSMethodSignature * sig = [[target class] instanceMethodSignatureForSelector:selector];
    pollCompleteCallback = [NSInvocation invocationWithMethodSignature:sig];
    pollCompleteCallback.target = target;
    pollCompleteCallback.selector = selector;
}

- (void)start
{
    isSpinning = YES;
    // Rotate about the z axis
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    // Rotate 360 degress, in direction specified
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 * SPIN_CLOCK_WISE];
    
    // Perform the rotation over this many seconds
    rotationAnimation.duration = 1;
    rotationAnimation.repeatCount = HUGE_VALF;
    
    // Set the pacing of the animation
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    // Add animation to the layer and make it so
    [self.imageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (BOOL)isPolling
{
    return isSpinning;
}

- (void)pollEquipmentId:(NSNumber *)equipmentId
{
    if (![DTConnection canSendMessages]) {
        [[UIAlertView alertViewForNotConnectedToInternet] show];
        return;
    }
    
    if (!isSpinning && self.state != UIControlStateDisabled) {
        [self start];
        
        pollOperation = [NSBlockOperation blockOperationWithBlock:^(void){
            DTResponse *response = [DTConnection getTo:FN3APIEquipmentPoll 
                                            parameters:[NSDictionary dictionaryWithObject:equipmentId forKey:@"id"]];
            if (response.isSuccess) {
                [self pollEquipmentId:equipmentId functionId:[response.data objectForKey:@"function_id"]];
            } else {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
                    if (response.isAuthenticationError) {
                        [[UIAlertView alertViewForNotAuthenticated] show];
                        [(DTAppDelegate *)[UIApplication sharedApplication].delegate showLoginPageAnimated:YES];
                    } else {
                        [[UIAlertView alertViewForResponse:response 
                                            defaultMessage:NSLocalizedString(@"There was an error while trying to poll.", nil)] show];
                    }
                        
                    [self stop];
                }];
            }
            
            pollOperation = nil;
        }];
        
        [[NSOperationQueue networkQueue] addNetworkOperation:pollOperation];
    }
}

- (void)pollEquipmentId:(NSNumber *)equipmentId functionId:(NSNumber *)functionId
{
    if (![DTConnection canSendMessages]) {
        return;
    }
    
    if (!isSpinning) {
        [self start];
    }
    
    self.isInPollError = NO;
    
    DTPollButton *this = self;
    __block BOOL success = NO;
    feedbackOperation = [NSBlockOperation blockOperationWithBlock:^(void){
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                equipmentId, @"id", 
                                functionId, @"function_id", nil];
        
        NSInteger feedbackCount = 0;
        while (!feedbackOperation.isCancelled) {
            DTResponse *res = [DTConnection getTo:FN3APIEquipmentFeedback 
                                       parameters:params];
            if (!feedbackOperation.isCancelled && res.isSuccess) {
                if ([[res.data objectForKey:@"complete"] boolValue]) {
                    success = YES;
                    break;
                }
                
                sleep(5);
            } else {
                if (!res.isSuccess) {
                    NSArray *errors = [NSArray arrayWithArray:[res errors]];
                    if ((errors == nil) || ([errors count] == 0)) {
                        NSLog(@"Feedback response was not successful. No additional information given.");
                    } else {
                        NSLog(@"Feedback response was not successful. Errors were: ");
                        int i = 0;
                        for (NSString *error in errors) {
                            i++;
                            NSLog(@"\n(%i): %@", i, error);
                        }
                    }
                    self.isInPollError = YES;
                    success = NO;
                }
                break;
            }
            
            feedbackCount++;
            
            if (feedbackCount >= 10) {
                self.isInPollError = YES;
                success = NO;
                break;
            }
        }
    }];
    
    NSInvocation *callback = pollCompleteCallback;
    feedbackOperation.completionBlock = ^(void) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
            [this stop];
            
            [callback setArgument:&success atIndex:2];
            [callback invoke];
        }];
    };
    
    [[NSOperationQueue networkQueue] addNetworkOperation:feedbackOperation];
}

- (void)stop
{
    [pollOperation cancel];
    pollOperation = nil;
    
    [feedbackOperation cancel];
    feedbackOperation = nil;
    
    
    [self.imageView.layer removeAllAnimations];
    isSpinning = NO;
}

@end
