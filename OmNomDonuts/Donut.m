//
//  Donut.m
//  OmNomDonuts
//
//  Created by John Z Wu on 5/18/14.
//
//

#import "Donut.h"

#import "SKNode+Control.h"

@implementation Donut

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [self invokeTargets];
}

@end
