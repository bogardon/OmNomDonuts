//
//  LifeCounterNode.m
//  OmNomDonuts
//
//  Created by John Z Wu on 9/13/14.
//
//

#import "LifeCounterNode.h"

#import "DonutFactory.h"
#import "Donut.h"

@implementation LifeCounterNode {
    NSInteger _maxLives;
}

- (id)initWithMaxLives:(NSInteger)maxLives
{
    self = [super init];
    if (self) {
      _maxLives = maxLives;
      DonutFactory *factory = [[DonutFactory alloc] init];
      for (int i = 0; i < maxLives; i++) {
          Donut *donut = [factory getDonutWithSize:CGSizeMake(20, 20)];
          donut.name = [@(i) description];
          donut.anchorPoint = CGPointMake(0, 0.5);
          donut.position = CGPointMake(i*20+i*5, 0);
          [self addChild:donut];
      }
    }
    return self;
}

- (void)setLives:(NSInteger)lives
{
    _lives = MAX(0, MIN(_maxLives, lives));

    for (int i = 0; i < _maxLives; i++) {
        Donut *donut = (Donut *)[self childNodeWithName:[@(i) description]];
        donut.hidden = i >= _lives;
    }
}

@end
