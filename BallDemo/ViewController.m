//
//  ViewController.m
//  BallDemo
//
//  Created by Marc Cuva on 5/12/13.
//  Copyright (c) 2013 Marc Cuva. All rights reserved.
//

#import "ViewController.h"
#import "BallView.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeRecognizer;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *pressRecognizer;
@property (strong, nonatomic) BallView *currentBall;
@end

@implementation ViewController

- (void)setCurrentBall:(BallView *)currentBall{
    _currentBall = currentBall;
}

- (IBAction)createBall:(UILongPressGestureRecognizer *)sender {
    if(sender.state == UIGestureRecognizerStateBegan){
        CGPoint location = [sender locationInView:self.view];
        self.currentBall = [[BallView alloc] initWithFrame:CGRectMake(location.x, location.y, .5, .5)];
        [self.view addSubview:self.currentBall];
        self.currentBall.ended = NO;
    }else if(sender.state == UIGestureRecognizerStateCancelled || sender.state == UIGestureRecognizerStateEnded){
        self.currentBall.ended = YES;
        self.currentBall = nil;
    }

}

- (IBAction)clearBalls:(UISwipeGestureRecognizer *)sender {
    for(BallView *view in self.view.subviews){
        [UIView animateWithDuration:.8 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            if(!view.animating)
                view.frame = CGRectMake(self.view.frame.size.width / 2, -view.frame.size.height, 0, 0);
        } completion:^(BOOL success){
            if(!view.animating)
                [view removeFromSuperview];
        }];
    }
}

@end
