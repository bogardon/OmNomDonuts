//
//  Catapult.h
//  OmNomDonuts
//
//  Created by jzw on 4/10/16.
//
//

#import <SpriteKit/SpriteKit.h>

@interface Catapult : NSObject

@property(nonatomic, strong) SKPhysicsJointSpring *fingerToDonutJoint;
@property(nonatomic, strong) SKNode *finger;

@end
