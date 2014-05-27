//
//  MyScene.m
//  OmNomDonuts
//
//  Created by John Z Wu on 4/27/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "MyScene.h"
#import "GameScene.h"

@implementation MyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        SKLabelNode *play = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        play.name = @"play";
        play.text = @"Play!";
        play.fontSize = 30;
        play.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));
        
        [self addChild:play];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    UITouch *touch = [touches anyObject];
    SKLabelNode *play = (SKLabelNode *)[self childNodeWithName:@"play"];
    if (CGRectContainsPoint(play.frame, [touch locationInView:touch.view])) {
        play.alpha = 0.5;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    SKLabelNode *play = (SKLabelNode *)[self childNodeWithName:@"play"];
    if (CGRectContainsPoint(play.frame, [touch locationInView:touch.view])) {
        play.alpha = 1;
        [self.view presentScene:[[GameScene alloc] initWithSize:self.size]];
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
