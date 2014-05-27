//
//  DonutFactory.m
//  OmNomDonuts
//
//  Created by John Z Wu on 5/18/14.
//
//

#import "DonutFactory.h"
#import "Donut.h"

@interface DonutFactory ()

@property (nonatomic, strong) SKTexture *donutTexture;

@end

@implementation DonutFactory

- (id)init
{
    self = [super init];
    if (self) {
        self.donutTexture = [SKTexture textureWithImageNamed:@"donut"];
    }
    return self;
}

- (Donut *)getDonutWithSize:(CGSize)size
{
    return [Donut spriteNodeWithTexture:self.donutTexture size:size];
}

@end
