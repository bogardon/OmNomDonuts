//
//  MissNode.m
//  OmNomDonuts
//
//  Created by jzw on 2/12/16.
//
//

#import "MissNode.h"

static const CGFloat kRadius = 5.0;
static const CGFloat kFadeDuration = 0.2;

@implementation MissNode

- (instancetype)init {
  self = [super init];
  if (self) {
    self.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-kRadius, -kRadius, 2 * kRadius,
                                                                   2 * kRadius)
                                           cornerRadius:kRadius]
                    .CGPath;
    self.fillColor = self.strokeColor = [SKColor redColor];
  }
  return self;
}

#pragma mark Public Methods

- (void)showAndHide {
  NSArray *actions = @[ [SKAction fadeOutWithDuration:kFadeDuration], [SKAction removeFromParent] ];
  SKAction *sequence = [SKAction sequence:actions];
  [self runAction:sequence];
}

@end
