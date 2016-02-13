//
//  LifeCounterNode.m
//  OmNomDonuts
//
//  Created by John Z Wu on 9/13/14.
//
//

#import "LifeCounterNode.h"

@implementation LifeCounterNode {
    NSInteger _maxLives;
}

- (id)initWithMaxLives:(NSInteger)maxLives {
  self = [super init];
  if (self) {
    _maxLives = maxLives;

    SKTexture *pink = [SKTexture textureWithImageNamed:@"pink_donut"];
    SKTexture *grey = [SKTexture textureWithImageNamed:@"greyout_donut"];
    for (int i = 0; i < maxLives; i++) {
      CGSize size = CGSizeMake(20, 20);
      SKSpriteNode *on = [SKSpriteNode spriteNodeWithTexture:pink size:size];
      SKSpriteNode *off = [SKSpriteNode spriteNodeWithTexture:grey size:size];
      on.name = [NSString stringWithFormat:@"pink%d", i];
      off.name = [NSString stringWithFormat:@"grey%d", i];
      on.anchorPoint = off.anchorPoint = CGPointMake(0, 0.5);
      on.position = off.position = CGPointMake(i*20+i*5, 0);
      [self addChild:off];
      [self addChild:on];
    }
  }
  return self;
}

- (void)setLives:(NSInteger)lives
{
    _lives = MAX(0, MIN(_maxLives, lives));

    for (int i = 0; i < _maxLives; i++) {
      NSString *name = [NSString stringWithFormat:@"pink%d", i];
      SKSpriteNode *on = (SKSpriteNode *)[self childNodeWithName:name];
      on.hidden = i >= _lives;
    }
}

@end
