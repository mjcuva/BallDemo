//
//  ViewController.m
//  Balls of Fun
//
//  Created by Marc Cuva on 5/12/13.
//  Copyright (c) 2013 Marc Cuva. All rights reserved.
//

#import "ViewController.h"
#import "GrowBallView.h"
#import "WallView.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeRecognizer;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *pressRecognizer;
@property (strong, nonatomic) GrowBallView *currentBall;
@end

@implementation ViewController

#define WALL_WIDTH 15

- (void)viewDidAppear:(BOOL)animated{
//    WallView *left = [[WallView alloc] initWithFrame:CGRectMake(0, 0, WALL_WIDTH, self.view.frame.size.height)];
//    [self.view addSubview:left];
//    
//    WallView *right = [[WallView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - WALL_WIDTH, 0,WALL_WIDTH, [self.view window].frame.size.height)];
//    [self.view addSubview:right];
//    
//    WallView *top = [[WallView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, WALL_WIDTH)];
//    [self.view addSubview:top];
//    
//    WallView *bottom = [[WallView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - WALL_WIDTH, self.view.frame.size.width, WALL_WIDTH)];
//    [self.view addSubview:bottom];
}

- (void)setCurrentBall:(GrowBallView *)currentBall{
    _currentBall = currentBall;
}

- (IBAction)createBall:(UILongPressGestureRecognizer *)sender {
    if(sender.state == UIGestureRecognizerStateBegan){
        CGPoint location = [sender locationInView:self.view];
        self.currentBall = [[GrowBallView alloc] initWithFrame:CGRectMake(location.x, location.y, .5, .5) andEdgeBounce:NO];
        [self.view addSubview:self.currentBall];
        self.currentBall.growing = YES;
    }else if(sender.state == UIGestureRecognizerStateCancelled || sender.state == UIGestureRecognizerStateEnded){
        self.currentBall.growing = NO;
        self.currentBall = nil;
    }

}

- (IBAction)clearBalls:(UISwipeGestureRecognizer *)sender {
    for(id view in self.view.subviews){
        if([view isKindOfClass:[GrowBallView class]]){
            [view removeBall];
        }
    }
}

@end
