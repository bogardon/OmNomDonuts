//
//  DonutFactory.h
//  OmNomDonuts
//
//  Created by John Z Wu on 5/18/14.
//
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@class Donut;

@interface DonutFactory : NSObject

- (Donut *)getDonutWithSize:(CGSize)size;

@end
