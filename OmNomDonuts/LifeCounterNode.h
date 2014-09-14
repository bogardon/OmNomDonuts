//
//  LifeCounterNode.h
//  OmNomDonuts
//
//  Created by John Z Wu on 9/13/14.
//
//

#import <SpriteKit/SpriteKit.h>

@interface LifeCounterNode : SKNode

- (id)initWithMaxLives:(NSInteger)maxLives;

@property (nonatomic, assign) NSInteger lives;

@end
