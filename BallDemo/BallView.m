//
//  BallView.m
//  Balls of Fun
//
//  Created by Marc Cuva on 5/12/13.
//  Copyright (c) 2013 Marc Cuva. All rights reserved.
//

#import "BallView.h"
#import "WallView.h"
#import "PressAndMoveGestureRecognizer.h"

@interface BallView()
@property (nonatomic, strong) UIColor *color;
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
    if(_speed > 0)
        [self move];
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];

        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeColor:)];
        [tapGesture setNumberOfTapsRequired:2];
        [self addGestureRecognizer:tapGesture];
        
        PressAndMoveGestureRecognizer *moveGesture = [[PressAndMoveGestureRecognizer alloc] initWithTarget:self action:@selector(moveBallWithTouch:)];
        [self addGestureRecognizer:moveGesture];
        
        [moveGesture requireGestureRecognizerToFail:tapGesture];
        
    }
    return self;
}

// Designated initializer with edge bounce
- (id)initWithFrame:(CGRect)frame
      andEdgeBounce:(BOOL)edgeBounce{
    self.edgeBounceEnabled = edgeBounce;
    return [self initWithFrame:frame];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(context, rect);
    CGContextSetFillColor(context, CGColorGetComponents([[self color] CGColor]));
    CGContextFillPath(context);
}


#pragma mark - Gestures


- (void)changeColor:(UITapGestureRecognizer *)sender{
    if(sender.state == UIGestureRecognizerStateRecognized){
        self.color = nil;
        [self setNeedsDisplay];
    }
}

#define SPEED_MODIFIER 3

- (void)moveBallWithTouch:(PressAndMoveGestureRecognizer *)sender{
    if(sender.state == UIGestureRecognizerStateRecognized || sender.state == UIGestureRecognizerStateChanged){
        if(sender.flick){
            CGPoint translation = sender.translation;
            CGFloat x = translation.x * SPEED_MODIFIER;
            CGFloat y = translation.y * SPEED_MODIFIER;
            CGFloat distance = sqrtf(x * x + y * y);
            
            self.direction = atan(translation.y/translation.x);
            
            // -x and x produce same atan direction
            if(translation.x < 0){
                self.direction += M_PI;
            }
            self.speed = distance;
        }else{
            self.speed = 0;
            CGPoint location = sender.location;
            self.center = location;
            sender.translation = CGPointZero;
        }
    }
}

#pragma mark - Movement

- (void)move{
    dispatch_queue_t movementQueue = dispatch_queue_create("Move", NULL);
    dispatch_async(movementQueue, ^{
        int __block loopCount = 500;
        CGFloat __block increaseFactor = 1.1;
        while(loopCount > 0 && self.speed > 0){
//            NSLog(@"%f", self.speed);
            dispatch_sync(dispatch_get_main_queue(), ^{
                @try{
                    self.frame = CGRectMake(self.frame.origin.x + (cos(self.direction) * self.speed / (100 * increaseFactor)), self.frame.origin.y + (sin(self.direction) * self.speed / (100 * increaseFactor)), self.frame.size.width, self.frame.size.height);
                    [self setNeedsDisplay];
                }@catch (NSException* ex) {
                    // catch just to prevent crash
                }
                
                loopCount -= 1;
                if(loopCount < 300)
                    increaseFactor += .08;
                                
                [self checkCollisions];
                
                if(self.edgeBounceEnabled){
                    [self checkEdgeBounce];
                }
            });
        }
        self.speed = 0;
        if(!CGRectIntersectsRect(self.frame, [[UIScreen mainScreen] applicationFrame])){
            // Remove view if non-visable
            // TODO: Sometimes issue where ball doesn't follow the remove gesture
            NSLog(@"Remove");
            [self removeFromSuperview];
        }

    });
}

#define BALL_INCREASE_FACTOR 1

- (void) checkCollisions{
    for (id view in self.superview.subviews){
        if([view isKindOfClass:[BallView class]]){
            BallView *ball = (BallView *)view;
            // Use pythagorean theorem to find the largest square that fits inside the circle.
            CGFloat insetSide = sqrtf((ball.frame.size.width * ball.frame.size.width) / 2);
            CGFloat offset = (ball.frame.size.height - insetSide) / 2;
            CGRect collisionMask = CGRectMake(ball.frame.origin.x + offset, ball.frame.origin.y + offset, insetSide, insetSide);
            if(CGRectIntersectsRect(collisionMask, self.frame) && self != ball){
                // Adjust frame to never be inside the collisionFrame
                // TODO: Fix Frame when balls collide to prevent getting stuck on each other
                ball.direction = self.direction;
                self.direction *= M_PI;
                NSLog(@"Ball Speed: %f", ball.speed);
                if(ball.speed == 0 || ball.speed < 100){
                    ball.speed = self.speed;
                }else{
//                    ball.speed *= BALL_INCREASE_FACTOR;
                }
            }
        }else if([view isKindOfClass:[WallView class]]){
            WallView *wall = (WallView *)view;
            if(CGRectIntersectsRect(self.frame, wall.frame)){
                CGRect intersect = CGRectIntersection(self.frame, wall.frame);
                NSLog(@"Origin:%f %f, Size:%f %f", intersect.origin.x, intersect.origin.y, intersect.size.width, intersect.size.height);
                NSLog(@"Origin:%f %f, Size:%f %f", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
                self.direction *= M_PI;
                
                // Checks if collision is on left of ball.
                if(intersect.origin.x - self.frame.origin.x == 0 && intersect.origin.y - self.frame.origin.y == 0 && intersect.size.height > intersect.size.width){
                    // TODO: Needs to be readjusted to work with all walls, not just walls on edge of superview
                    self.frame = CGRectMake(self.superview.frame.origin.x + wall.frame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
                }
            }
        }
    }
}

#define OFFSET 50

- (void)checkEdgeBounce{
    if(self.frame.origin.x < self.superview.frame.origin.x - OFFSET){
        self.direction *= M_PI;
        self.frame = CGRectMake(self.superview.frame.origin.x - OFFSET, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    }else if(self.frame.origin.x + self.frame.size.width > self.superview.frame.size.width + OFFSET){
        self.direction *= M_PI;
        self.frame = CGRectMake(self.superview.frame.size.width - self.frame.size.width + OFFSET, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    }
    
    if(self.frame.origin.y < self.superview.frame.origin.y - OFFSET){
        self.direction *= M_PI;
        self.frame = CGRectMake(self.frame.origin.x, self.superview.frame.origin.y - OFFSET, self.frame.size.width, self.frame.size.height);
    }else if(self.frame.origin.y + self.frame.size.height > self.superview.frame.size.height + OFFSET){
        self.direction *= M_PI;
        self.frame = CGRectMake(self.frame.origin.x, self.superview.frame.size.height - self.frame.size.height + OFFSET, self.frame.size.width, self.frame.size.height);
    }
}

@end
