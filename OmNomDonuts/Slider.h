#import <SpriteKit/SpriteKit.h>

@interface Slider : SKNode
@property(nonatomic, copy) NSString *title;
@property(nonatomic, assign) CGFloat minValue;
@property(nonatomic, assign) CGFloat maxValue;
@property(nonatomic, assign) CGFloat currentValue;
@property(nonatomic, assign) CGFloat scale;
@property(nonatomic, strong) SKColor *color;
@end
