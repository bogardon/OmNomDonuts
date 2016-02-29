//
//  LifeCounterNode.m
//  OmNomDonuts
//
//  Created by John Z Wu on 9/13/14.
//
//

#import "LifeCounterNode.h"

static const CGSize kLifeSize = {20, 20};
static const CGFloat kPadding = 5.0;

@interface LifeCounterNode ()
@property(nonatomic, assign) NSInteger currentLives;
@end

@implementation LifeCounterNode {
  NSInteger _maxLives;
}

- (instancetype)initWithMaxLives:(NSInteger)maxLives {
  self = [super init];
  if (self) {
    _maxLives = maxLives;

    SKTexture *pink;
    SKTexture *grey;
    for (int i = 0; i < maxLives; i++) {
      SKSpriteNode *on = [SKSpriteNode spriteNodeWithTexture:pink size:kLifeSize];
      SKSpriteNode *off = [SKSpriteNode spriteNodeWithTexture:grey size:kLifeSize];
      on.name = [NSString stringWithFormat:@"pink%d", i];
      off.name = [NSString stringWithFormat:@"grey%d", i];
      on.anchorPoint = off.anchorPoint = CGPointMake(0, 0.5);
      on.position = off.position = CGPointMake(i * kLifeSize.width + i * kPadding, 0);
      [self addChild:off];
      [self addChild:on];
    }

    [self reset];
  }
  return self;
}

#pragma mark Public Methods

- (void)reset {
  self.currentLives = _maxLives;
}

- (void)decrementLives {
  self.currentLives--;
}

- (void)setCurrentLives:(NSInteger)currentLives {
  _currentLives = MAX(0, MIN(_maxLives, currentLives));

  for (int i = 0; i < _maxLives; i++) {
    NSString *name = [NSString stringWithFormat:@"pink%d", i];
    SKSpriteNode *on = (SKSpriteNode *)[self childNodeWithName:name];
    on.hidden = i >= _currentLives;
  }
}

@end
