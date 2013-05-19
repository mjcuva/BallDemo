//
//  BallView.m
//  Balls of Fun
//
//  Created by Marc Cuva on 5/12/13.
//  Copyright (c) 2013 Marc Cuva. All rights reserved.
//

#import "BallView.h"

@interface BallView()
@property (nonatomic) CGFloat direction; // Angle in radians
@property (nonatomic, strong) UIColor *color;
@property (nonatomic) CGFloat speed;
@end

@implementation BallView

#pragma mark - Properties

- (UIColor *)color{
    if(!_color){
        NSArray *colors = @[[UIColor greenColor], [UIColor redColor], [UIColor blueColor], [UIColor purpleColor], [UIColor orangeColor], [UIColor yellowColor], [UIColor cyanColor]];
        NSUInteger random = arc4random() % [colors count];
        _color = colors[random];
    }
    return _color;
}

- (void)setSpeed:(CGFloat)speed{
    _speed = speed;
    [self move];
}


#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(flickInDirection:)];
        [self addGestureRecognizer:panGesture];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeColor:)];
        [tapGesture setNumberOfTapsRequired:2];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(context, rect);
    CGContextSetFillColor(context, CGColorGetComponents([[self color] CGColor]));
    CGContextFillPath(context);
}


#pragma mark - Gestures

- (void)flickInDirection:(UIPanGestureRecognizer *)sender{
    if(sender.state == UIGestureRecognizerStateRecognized){
        CGPoint translation = [sender translationInView:self.superview];
        CGFloat x = translation.x * 4;
        CGFloat y = translation.y * 4;
        CGFloat distance = sqrtf(x * x + y * y);
        
        self.direction = atan(translation.y/translation.x);
        
        // -x and x produce same atan direction
        if(translation.x < 0){
            self.direction += M_PI;
        }
        self.speed = distance;
    }
}

- (void)changeColor:(UITapGestureRecognizer *)sender{
    if(sender.state == UIGestureRecognizerStateRecognized){
        self.color = nil;
        [self setNeedsDisplay];
    }
}

#define OFFSET 50

- (void)move{
    dispatch_queue_t movementQueue = dispatch_queue_create("Move", NULL);
    dispatch_async(movementQueue, ^{
        int loopCount = 500;
        CGFloat increaseFactor = 1.1;
        while(loopCount > 0){
            dispatch_sync(dispatch_get_main_queue(), ^{
                @try{
                    self.frame = CGRectMake(self.frame.origin.x + (cos(self.direction) * self.speed / (100 * increaseFactor)), self.frame.origin.y + (sin(self.direction) * self.speed / (100 * increaseFactor)), self.frame.size.width, self.frame.size.height);
                    [self setNeedsDisplay];
                }@catch (NSException* ex) {
                    // catch just to prevent crash
                }
            });
            loopCount -= 1;
            if(loopCount < 300)
                increaseFactor += .08;
            
            if(self.frame.origin.x < self.superview.bounds.origin.x - OFFSET){
                self.direction *= M_PI;
                self.frame = CGRectMake(self.superview.bounds.origin.x - OFFSET, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
            }else if(self.frame.origin.x + self.frame.size.width > self.superview.bounds.size.width + OFFSET){
                self.direction *= M_PI;
                self.frame = CGRectMake(self.superview.bounds.size.width - self.frame.size.width + OFFSET, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
            }
            
            if(self.frame.origin.y < self.superview.bounds.origin.y - OFFSET){
                self.direction *= M_PI;
                self.frame = CGRectMake(self.frame.origin.x, self.superview.bounds.origin.y - OFFSET, self.frame.size.width, self.frame.size.height);
            }else if(self.frame.origin.y + self.frame.size.height > self.superview.bounds.size.height + OFFSET){
                self.direction *= M_PI;
                self.frame = CGRectMake(self.frame.origin.x, self.superview.bounds.size.height - self.frame.size.height + OFFSET, self.frame.size.width, self.frame.size.height);
            }

        }
    });
}



@end
