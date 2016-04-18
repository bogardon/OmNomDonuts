//
//  Difficulty.h
//  OmNomDonuts
//
//  Created by jzw on 2/29/16.
//
//

#import <Foundation/Foundation.h>

@interface GameConfig : NSObject

@property(nonatomic, assign) NSTimeInterval deployPeriod;
@property(nonatomic, assign) NSInteger numberOfDonutsPerDeploy;
@property(nonatomic, assign) NSInteger maxLives;
@property(nonatomic, assign) CGFloat contractSpeed;

@end
