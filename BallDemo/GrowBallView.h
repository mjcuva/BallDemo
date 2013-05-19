//
//  growBallView.h
//  Balls of Fun
//
//  Created by Marc Cuva on 5/17/13.
//  Copyright (c) 2013 Marc Cuva. All rights reserved.
//

#import "BallView.h"

@interface GrowBallView : BallView
@property (nonatomic) BOOL growing;

- (void) removeBall;
@end
