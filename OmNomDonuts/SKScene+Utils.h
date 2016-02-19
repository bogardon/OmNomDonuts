//
//  SKScene+Utils.h
//  OmNomDonuts
//
//  Created by jzw on 2/18/16.
//
//

#import <SpriteKit/SpriteKit.h>

@class Donut;

@interface SKScene (Utils)

@property(nonatomic, readonly) NSArray<Donut *> *allDonuts;
@property(nonatomic, readonly) NSArray<Donut *> *pendingDonuts;

@end
