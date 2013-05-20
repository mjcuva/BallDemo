//
//  PressAndMoveGestureRecognizer.h
//  Balls of Fun
//
//  Created by Marc Cuva on 5/18/13.
//  Copyright (c) 2013 Marc Cuva. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PressAndMoveGestureRecognizer : UIGestureRecognizer
@property (nonatomic) CGPoint translation;
@property (nonatomic) BOOL flick;
@property (nonatomic) CGPoint location;
@end
