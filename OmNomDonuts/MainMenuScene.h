//
//  MyScene.h
//  OmNomDonuts
//

//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class MainMenuScene;

@protocol MainMenuSceneDelegate <NSObject>

- (void)mainMenuSceneDidPlayGame:(MainMenuScene *)mainMenuScene;

@end

@interface MainMenuScene : SKScene

@property (nonatomic, weak) id <MainMenuSceneDelegate> delegate;

@end
