//
//  BouncingDonut.h
//  OmNomDonuts
//
//  Created by jzw on 4/10/16.
//
//

#import <SpriteKit/SpriteKit.h>

#import "Donut.h"
#import "Catapult.h"

@interface BouncingDonut : SKSpriteNode<Donut>

@property(nonatomic, strong) Catapult *catapult;

@end
