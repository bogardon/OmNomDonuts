//
//  ScoreCounterNode.m
//  OmNomDonuts
//
//  Created by jzw on 2/12/16.
//
//

#import "ScoreCounterNode.h"

static const CGFloat kStepDelay = 0.05;

@implementation ScoreCounterNode

#pragma mark Public Methods

- (void)setScore:(NSInteger)score {
  [self setScore:score animated:YES];
}

- (void)setScore:(NSInteger)score animated:(BOOL)animated {
  _score = MAX(0, score);

  if (!animated) {
    self.text = [@(score) description];
    return;
  }

  NSInteger displayedScore = self.text.integerValue;
  NSInteger difference = score - displayedScore;
  NSInteger step = difference / ABS(difference);
  NSArray *actions = @[
    [SKAction runBlock:^{
      self.text = [@(self.text.integerValue + step) description];
    }],
    [SKAction waitForDuration:kStepDelay]
  ];
  SKAction *sequence = [SKAction sequence:actions];

  [self removeAllActions];
  [self runAction:[SKAction repeatAction:sequence count:ABS(score - displayedScore)]];
}

- (void)reset {
  [self setScore:0 animated:NO];
}

@end
