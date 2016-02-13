//
//  GameScene.h
//  OmNomDonuts
//
//  Created by John Z Wu on 4/27/14.
//
//

#import <SpriteKit/SpriteKit.h>

typedef NS_OPTIONS(NSUInteger, GameplayEffect) {
  GameplayEffectNone                 = 0,
  GameplayEffectSlowDown             = 1 << 0,
};

@interface GameScene : SKScene
@end
