//
//  ScoreCounterNode.h
//  OmNomDonuts
//
//  Created by jzw on 2/12/16.
//
//

#import <SpriteKit/SpriteKit.h>

@interface ScoreCounterNode : SKLabelNode

@property(nonatomic, assign) NSInteger score;

- (void)reset;
- (void)setScore:(NSInteger)score animated:(BOOL)animated;

@end
