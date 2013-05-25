//
//  WallView.m
//  Balls of Fun
//
//  Created by Marc Cuva on 5/24/13.
//  Copyright (c) 2013 Marc Cuva. All rights reserved.
//

#import "WallView.h"

@implementation WallView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor yellowColor]];
    }
    return self;
}



- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddRect(context, rect);
    CGContextSetFillColor(context, CGColorGetComponents([[UIColor yellowColor] CGColor]));
//    CGContextSetBlendMode(context, kCGBlendModeLighten);
    CGContextFillPath(context);
}

@end
