//
//  DTPumpGaugeView.m
//  FN3
//
//  Created by David Jablonski on 4/11/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTPumpGaugeView.h"
#import "DTFunctions.h"

#import "UIColor+DTColor.h"
#import "NSArray+DTArray.h"

#import "DTGauge.h"
#import "DTGaugeColor.h"
#import "DTGaugeMarker.h"


@implementation DTPumpGaugeView

@synthesize needleAngle, minValue, maxValue;

- (void)dealloc
{
    colors = startAngles = endAngles = nil;
    markerColors = markerAngles = nil;
    views = viewAngles = nil;
    minValue = nil;
    maxValue = nil;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    
    colors = [[NSMutableArray alloc] init];
    startAngles = [[NSMutableArray alloc] init];
    endAngles = [[NSMutableArray alloc] init];
    
    markerColors = [[NSMutableArray alloc] init];
    markerAngles = [[NSMutableArray alloc] init];
    
    views = [[NSMutableArray alloc] init];
    viewAngles = [[NSMutableArray alloc] init];
    
    width = 24;
    
    minValue = [[UILabel alloc] init];
    minValue.font = [minValue.font fontWithSize:12];
    minValue.adjustsFontSizeToFitWidth = YES;
    minValue.backgroundColor = [UIColor clearColor]; 
    [self addSubview:minValue];
    
    maxValue = [[UILabel alloc] init];
    maxValue.font = [maxValue.font fontWithSize:12];
    maxValue.adjustsFontSizeToFitWidth = YES;
    maxValue.backgroundColor = [UIColor clearColor]; 
    [self addSubview:maxValue];
}

- (void)reset
{
    [colors removeAllObjects];
    [startAngles removeAllObjects];
    [endAngles removeAllObjects];
    
    [markerColors removeAllObjects];
    [markerAngles removeAllObjects];
    
    for (UIView *v in views) {
        [v removeFromSuperview];
    }
    [views removeAllObjects];
    [viewAngles removeAllObjects];
    
    minValue.text = maxValue.text = nil;
}

- (void)configureFromGauge:(DTGauge *)gauge
{
    [self reset];
    
    CGFloat factor = 180.0 / (gauge.max.floatValue - gauge.min.floatValue);
    if (factor == INFINITY) {
        factor = 0;
    }
    
    NSArray *gaugeColors = [gauge.colors.allObjects sortedArrayUsingComparator:^NSComparisonResult(DTGaugeColor *c1, DTGaugeColor *c2) {
        return [c1.order compare:c2.order];
    }];
    for (DTGaugeColor *color in gaugeColors) {
        CGFloat max = factor == 0 && color.max.floatValue == gauge.max.floatValue ? 180 : color.max.floatValue * factor;
        [self addGaugeColor:[UIColor colorFromHexString:color.color] 
                  fromAngle:color.min.floatValue * factor
                    toAngle:max];
    }
    
    self.needleAngle = gauge.value.floatValue * factor;
    
    NSArray *markers = [gauge.markers.allObjects sortedArrayUsingComparator:^NSComparisonResult(DTGaugeMarker *m1, DTGaugeMarker *m2) {
        return [m1.order compare:m2.order];
    }];
    for (DTGaugeMarker *marker in markers) {
        [self addMarkerWithColor:[UIColor colorFromHexString:marker.fillColor]
                         atAngle:marker.value.floatValue * factor];
        
        if (marker.label) {
            [self addText:marker.label atAngle:marker.value.floatValue * factor];
        }
    }
    
    NSNumberFormatter *numberFormat = [[NSNumberFormatter alloc] init];
    numberFormat.maximumFractionDigits = 0;
    [numberFormat setNumberStyle:NSNumberFormatterDecimalStyle];
    
    self.minValue.text = [numberFormat stringFromNumber:gauge.min];
    self.maxValue.text = [numberFormat stringFromNumber:gauge.max];
    
    [self setNeedsDisplay];
}

- (void)addGaugeColor:(UIColor *)color fromAngle:(CGFloat)from toAngle:(CGFloat)to
{
    [colors addObject:color];
    [startAngles addObject:[NSNumber numberWithFloat:from]];
    [endAngles addObject:[NSNumber numberWithFloat:to]];
}

- (void)addText:(NSString *)text atAngle:(CGFloat)angle
{
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:14];
    label.text = text;
    label.adjustsFontSizeToFitWidth = YES;
    label.backgroundColor = [UIColor clearColor]; 
    
    CGSize size = [label sizeThatFits:CGSizeZero];
    label.frame = CGRectMake(0, 0, size.width, size.height);
    
    [self addView:label atAngle:angle];
}

- (void)addView:(UIView *)view atAngle:(CGFloat)angle
{
    [viewAngles addObject:[NSNumber numberWithFloat:angle]];
    [views addObject:view];
}

- (void)addMarkerWithColor:(UIColor *)color atAngle:(CGFloat)angle
{
    [markerAngles addObject:[NSNumber numberWithFloat:angle]];
    [markerColors addObject:color];
}

- (void)drawRect:(CGRect)rect
{
    if (colors.count > 0) {
        CGFloat radius = rect.size.height - 44;
        CGPoint center = CGPointMake(rect.size.width / 2.0, rect.size.height - 23.5);
        
        if (self.minValue.text.length > 0) {
            CGPoint point = DTArcPoint(center, radius, DTRadiansFromDegrees(-180));
            CGSize size = [minValue sizeThatFits:CGSizeZero];
            minValue.frame = CGRectMake(point.x - (size.width / 2.0), 
                                        point.y + 3, 
                                        size.width, 
                                        size.height);
        }
        
        if (self.maxValue.text.length > 0) {
            CGPoint point = DTArcPoint(center, radius, 0);
            CGSize size = [maxValue sizeThatFits:CGSizeZero];
            maxValue.frame = CGRectMake(point.x - (size.width / 2.0), 
                                        point.y + 3, 
                                        size.width, 
                                        size.height);
        }
        
        [self drawGaugeWithCenter:center andRadius:radius];
        [self drawMarkersWithCenter:center andRadius:radius];
        [self drawNeedleWithCenter:center andRadius:radius];
        [self drawLabelsWithCenter:center andRadius:radius];
    }
}

- (void)drawGaugeWithCenter:(CGPoint)center andRadius:(CGFloat)radius
{
    for (int i = 0; i < colors.count; i++) {
        UIColor *color = [colors objectAtIndex:i];
        CGFloat startDegrees = [[startAngles objectAtIndex:i] floatValue];
        CGFloat endDegrees = [[endAngles objectAtIndex:i] floatValue];
        CGFloat startAngle = DTRadiansFromDegrees(-180 + startDegrees);
        CGFloat endAngle = DTRadiansFromDegrees(-180 + endDegrees);
        
        UIBezierPath *gauge = [UIBezierPath bezierPath];
        [gauge moveToPoint:DTArcPoint(center, radius - (width / 2.0), startAngle)];
        [gauge addLineToPoint:DTArcPoint(center, radius + (width / 2.0), startAngle)];
        [gauge addArcWithCenter:center 
                         radius:radius + (width / 2.0) 
                     startAngle:startAngle 
                       endAngle:endAngle 
                      clockwise:YES];
        [gauge addLineToPoint:DTArcPoint(center, radius - (width / 2.0), endAngle)];
        [gauge addArcWithCenter:center 
                         radius:radius - (width / 2.0) 
                     startAngle:endAngle 
                       endAngle:startAngle 
                      clockwise:NO];
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //// Gradient Declarations
        NSArray* gradientColors = [NSArray arrayWithObjects: 
                                   (id)color.CGColor, 
                                   (id)[color lighterColor].CGColor, 
                                   (id)color.CGColor, nil];
        CGFloat gradientLocations[] = {0.25, 0.7, 0.95};
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);

        CGContextSaveGState(context);
        [gauge addClip];
        CGContextDrawRadialGradient(context, gradient, center, radius - (width / 2.0), center, radius + (width / 2.0), 0);

        CGContextRestoreGState(context);
        
        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorSpace);
    }
    
    UIBezierPath *gaugeBorder = [UIBezierPath bezierPath];
    [gaugeBorder moveToPoint:DTArcPoint(center, radius - (width / 2.0), DTRadiansFromDegrees(-180))];
    [gaugeBorder addLineToPoint:DTArcPoint(center, radius + (width / 2.0), DTRadiansFromDegrees(-180))];
    [gaugeBorder addArcWithCenter:center 
                     radius:radius + (width / 2.0) 
                 startAngle:DTRadiansFromDegrees(-180)
                   endAngle:0
                  clockwise:YES];
    [gaugeBorder addLineToPoint:DTArcPoint(center, radius - (width / 2.0), 0)];
    [gaugeBorder addArcWithCenter:center 
                     radius:radius - (width / 2.0) 
                 startAngle:0
                   endAngle:DTRadiansFromDegrees(-180)
                  clockwise:NO];
    [gaugeBorder setLineWidth:0.3];
    [[UIColor blackColor] setStroke];
    [gaugeBorder stroke];
    
    // add the tick marks
    for (int i = 1; i < 20; i++) {
        NSInteger degrees = -180 + (9 * i);
        CGFloat length = degrees % 36 == 0 ? 5 : 2;
        CGFloat angle = DTRadiansFromDegrees(degrees);
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:DTArcPoint(center, radius + (width / 2.0), angle)];
        [path addLineToPoint:DTArcPoint(center, radius + (width / 2.0) - length, angle)];
        [path setLineWidth:length == 5 ? 2 : 1];
        [[UIColor blackColor] setStroke];
        [path stroke];
    }
}

- (void)drawNeedleWithCenter:(CGPoint)center andRadius:(CGFloat)radius
{
    [[UIColor whiteColor] setFill];
    [[UIColor blackColor] setStroke];
    
    CGPoint needleBackPoint = CGPointMake(center.x, center.y + 1);
    
    // draw the needle
    CGPoint needlePoint = DTArcPoint(center, radius - 3, DTRadiansFromDegrees(-180 + needleAngle));
    CGPoint backPoint1 = DTArcPoint(needleBackPoint, 7, DTRadiansFromDegrees(-360 + needleAngle + 90));
    CGPoint backPoint2 = DTArcPoint(needleBackPoint, 7, DTRadiansFromDegrees(-360 + needleAngle - 90));
    
    UIBezierPath *needle = [UIBezierPath bezierPath];
    [needle setLineJoinStyle:kCGLineJoinRound];
    [needle setLineCapStyle:kCGLineCapRound];
    [needle moveToPoint:backPoint1];
    [needle addLineToPoint:needlePoint];
    [needle addLineToPoint:backPoint2];
    [needle addArcWithCenter:needleBackPoint
                      radius:7
                  startAngle:DTRadiansFromDegrees(-360 + needleAngle - 90) 
                    endAngle:DTRadiansFromDegrees(-360 + needleAngle + 90) 
                   clockwise:YES];
    [needle fill];
    [needle stroke];
    
    // draw a circle at the center to serve as the needle pivot point
    UIBezierPath *pivotCenter = [UIBezierPath bezierPath];
    [pivotCenter addArcWithCenter:needleBackPoint
                           radius:3.5
                       startAngle:0 
                         endAngle:2 * M_PI 
                        clockwise:YES];
    [pivotCenter fill];
    [pivotCenter stroke];
}

- (void)drawMarkersWithCenter:(CGPoint)center andRadius:(CGFloat)radius
{
    for (int i = 0; i < markerAngles.count; i++) {
        CGFloat angle = [[markerAngles objectAtIndex:i] floatValue];
        UIColor *color = [markerColors objectAtIndex:i];
        
        CGPoint startPoint = DTArcPoint(center, radius + (width / 2), DTRadiansFromDegrees(-180 + angle));
        CGPoint endPoint = DTArcPoint(center, radius - (width / 2), DTRadiansFromDegrees(-180 + angle));
        UIBezierPath *line = [UIBezierPath bezierPath];
        [line moveToPoint:startPoint];
        [line addLineToPoint:endPoint];
        
        CGFloat length = width / 8;
        CGFloat pattern[8];
        for (int i = 0; i < 8; i++) {
            pattern[i] = length;
        }
        [line setLineDash:pattern count:8 phase:0];
        
        [[UIColor blackColor] setStroke];
        [line stroke];
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        // move to the back left
        [path moveToPoint:DTArcPoint(center, radius + (width / 2) + 3, DTRadiansFromDegrees(-180 + angle - 3))];
        // add a line toward the gauge
        [path addLineToPoint:DTArcPoint(center, radius + (width / 2) + 1, DTRadiansFromDegrees(-180 + angle - 3))];
        // add a line to the point
        [path addLineToPoint:DTArcPoint(center, radius + (width / 2) - 4, DTRadiansFromDegrees(-180 + angle))];
        // add a line back and to the right
        [path addLineToPoint:DTArcPoint(center, radius + (width / 2) + 1, DTRadiansFromDegrees(-180 + angle + 3))];
        // add a line straight back for the back right point
        [path addLineToPoint:DTArcPoint(center, radius + (width / 2) + 3, DTRadiansFromDegrees(-180 + angle + 3))];
        // connect the back points
        [path addArcWithCenter:center radius:radius + (width / 2) + 3 
                    startAngle:DTRadiansFromDegrees(-180 + angle + 3)  
                      endAngle:DTRadiansFromDegrees(-180 + angle - 3)
                     clockwise:NO];
        
        [path setLineCapStyle:kCGLineCapRound];
        [path setLineJoinStyle:kCGLineJoinRound];
        [path setLineWidth:0.5];
        [color setFill];
        [[UIColor blackColor] setStroke];
        [path fill];
        [path stroke];
    }
}

- (void)drawLabelsWithCenter:(CGPoint)center andRadius:(CGFloat)radius
{
    for (int i = 0; i < views.count; i++) {
        CGFloat angle = [[viewAngles objectAtIndex:i] floatValue];
        
        UIView *view = [views objectAtIndex:i];
        
        CGSize size = view.frame.size;
        CGPoint point = DTArcPoint(center, radius + (width / 2) + 10, DTRadiansFromDegrees(-180 + angle));
        CGFloat x, y;
        x = point.x;
        y = point.y - size.height;
        
        if (angle < 90) {
            x -= size.width;
            y += size.height / 2;
        } else if (angle > 90) {
            y += size.height / 2;
        } else {
            x -= size.width / 2;
        }
        
        view.frame = CGRectMake(x, y, size.width, size.height);
        if (view.frame.origin.x + view.frame.size.width > (self.frame.size.width - 5)) {
            view.frame = CGRectMake(view.frame.origin.x, 
                                     view.frame.origin.y, 
                                     self.frame.size.width - 5 - view.frame.origin.x, 
                                     view.frame.size.height);
        } else if (view.frame.origin.x < 5) {
            view.frame = CGRectMake(5, 
                                    view.frame.origin.y, 
                                    view.frame.size.width - (5 - view.frame.origin.x), 
                                    view.frame.size.height);
        }
        
        [self addSubview:view];
    }
}

@end
