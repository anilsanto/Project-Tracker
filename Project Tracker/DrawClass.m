//
//  DrawClass.m
//  Project Tracker
//
//  Created by Nuevalgo on 24/02/14.
//  Copyright (c) 2014 Nuevalgo. All rights reserved.
//

#import "DrawClass.h"

@implementation DrawClass

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 194.0/255.0, 194.0/255.0, 194.0/255.0, 1.0);
    
    
    CGFloat radius = 6.0;
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextFillRect(context, rect);
    
    CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
    CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);
    
    CGContextMoveToPoint(context, minx, midy);
    
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
   
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
   
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);

    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    
    CGContextClosePath(context);
    
    CGContextDrawPath(context, kCGPathStroke);

}

@end
