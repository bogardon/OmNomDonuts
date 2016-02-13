//
//  LifeCounterNode.h
//  OmNomDonuts
//
//  Created by John Z Wu on 9/13/14.
//
//

#import <SpriteKit/SpriteKit.h>

@interface LifeCounterNode : SKNode

- (instancetype)initWithMaxLives:(NSInteger)maxLives;

- (void)reset;

- (void)decrementLives;

@end
