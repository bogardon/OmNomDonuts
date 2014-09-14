//
//  GameScene.h
//  OmNomDonuts
//
//  Created by John Z Wu on 4/27/14.
//
//

typedef NS_ENUM(NSInteger, GameState){
    GameStatePlaying,
    GameStatePaused,
    GameStateLost
};

#import <SpriteKit/SpriteKit.h>

@class MainMenuScene;

@interface GameScene : SKScene

- (void)resetGame;

@property(nonatomic, assign) GameState state;

@end
