//
//  SKScene+Utils.h
//  OmNomDonuts
//
//  Created by jzw on 2/18/16.
//
//

#import <SpriteKit/SpriteKit.h>

@protocol Donut;

@interface SKNode (Utils)

@property(nonatomic, readonly) NSArray<SKSpriteNode<Donut> *> *allDonuts;
@property(nonatomic, readonly) NSArray<SKSpriteNode<Donut> *> *pendingDonuts;

@end
