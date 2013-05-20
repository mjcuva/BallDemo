//
//  PressAndMoveGestureRecognizer.m
//  Balls of Fun
//
//  Created by Marc Cuva on 5/18/13.
//  Copyright (c) 2013 Marc Cuva. All rights reserved.
//

#import "PressAndMoveGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface PressAndMoveGestureRecognizer()
@property (nonatomic) CGPoint previous;
@property (nonatomic) CGPoint initial;
@property (nonatomic) NSDate *start;
@end

@implementation PressAndMoveGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    if([touches count] != 1){
        self.state = UIGestureRecognizerStateFailed;
    }else{
        self.previous = self.initial = [touches.anyObject locationInView:[self.view window]];
        self.start = [NSDate date];
        self.state = UIGestureRecognizerStatePossible;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    if([touches count] > 1){
        self.state = UIGestureRecognizerStateFailed;
    }else{
        UIWindow *win = [self.view window];
        CGPoint point = [touches.anyObject locationInView:win];
        self.translation = CGPointMake(point.x - self.previous.x, point.y - self.previous.y);
        self.location = self.previous = point;
        self.state = UIGestureRecognizerStateChanged;
        if([[NSDate date] timeIntervalSinceDate:self.start] > .5){
            self.flick = NO;
        }else{
            self.flick = YES;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    self.state = UIGestureRecognizerStateRecognized;
    if([[NSDate date] timeIntervalSinceDate:self.start] > .5){
        self.flick = NO;
    }else{
        self.flick = YES;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
    self.translation = CGPointZero;
    self.state = UIGestureRecognizerStateCancelled;
}

- (void)reset{
    [super reset];
    self.previous = CGPointZero;
    self.translation = CGPointZero;
}

@end
