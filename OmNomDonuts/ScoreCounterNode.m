#import "ScoreCounterNode.h"

static const NSTimeInterval kUpdateDuration = 0.5;

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
  NSTimeInterval stepDelay = kUpdateDuration / difference;
  NSArray *actions = @[
    [SKAction runBlock:^{
      self.text = [@(self.text.integerValue + step) description];
    }],
    [SKAction waitForDuration:stepDelay]
  ];
  SKAction *sequence = [SKAction sequence:actions];

  [self removeAllActions];
  [self runAction:[SKAction repeatAction:sequence count:ABS(score - displayedScore)]];
}

- (void)reset {
  [self setScore:0 animated:NO];
}

@end
