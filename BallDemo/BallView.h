//
//  BallView.h
//  Balls of Fun
//
//  Created by Marc Cuva on 5/12/13.
//  Copyright (c) 2013 Marc Cuva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PressAndMoveGestureRecognizer.h"

@interface BallView : UIView
@property (nonatomic) CGFloat speed;
@property (nonatomic) CGFloat direction; // Angle in radians
@property (nonatomic) BOOL edgeBounceEnabled; // Defaults to YES

// Designated initializer
- (id)initWithFrame:(CGRect)frame
      andEdgeBounce:(BOOL)edgeBounce;

@end
