//
//  PauseNode.m
//  OmNomDonuts
//
//  Created by jzw on 2/12/16.
//
//

#import "PauseNode.h"

#import "SKNode+Control.h"

static const CGFloat kNormalAlpha = 0.7;
static const CGFloat kHighlightedAlpha = 0.3;

@implementation PauseNode

- (instancetype)init {
  self = [super init];
  if (self) {
    self.userInteractionEnabled = YES;
    self.lineWidth = 0;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointZero];
    [path addLineToPoint:CGPointMake(0, 16)];
    [path addLineToPoint:CGPointMake(4, 16)];
    [path addLineToPoint:CGPointMake(4, 0)];
    [path closePath];
    [path moveToPoint:CGPointMake(8, 0)];
    [path addLineToPoint:CGPointMake(8, 16)];
    [path addLineToPoint:CGPointMake(12, 16)];
    [path addLineToPoint:CGPointMake(12, 0)];
    [path closePath];
    self.fillColor = [[UIColor blackColor] colorWithAlphaComponent:kNormalAlpha];
    self.path = path.CGPath;
  }
  return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  self.fillColor = [[UIColor blackColor] colorWithAlphaComponent:kHighlightedAlpha];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  self.fillColor = [[UIColor blackColor] colorWithAlphaComponent:kNormalAlpha];

  [self invokeTargets];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  self.fillColor = [[UIColor blackColor] colorWithAlphaComponent:kNormalAlpha];
}

@end
