#import "PauseNode.h"

#import "SKNode+Control.h"

static const CGFloat kNormalAlpha = 0.7;
static const CGFloat kHighlightedAlpha = 0.3;

@implementation PauseNode {
  SKShapeNode *_shapeNode;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    self.userInteractionEnabled = YES;
    self.size = CGSizeMake(40, 40);

    _shapeNode = [[SKShapeNode alloc] init];
    _shapeNode.lineWidth = 0;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(0, 16)];
    [path addLineToPoint:CGPointMake(4, 16)];
    [path addLineToPoint:CGPointMake(4, 0)];
    [path closePath];
    [path moveToPoint:CGPointMake(8, 0)];
    [path addLineToPoint:CGPointMake(8, 16)];
    [path addLineToPoint:CGPointMake(12, 16)];
    [path addLineToPoint:CGPointMake(12, 0)];
    [path closePath];
    _shapeNode.fillColor = [[UIColor blackColor] colorWithAlphaComponent:kNormalAlpha];
    _shapeNode.path = path.CGPath;
    _shapeNode.position = CGPointMake(14, 12);
    [self addChild:_shapeNode];
  }
  return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  _shapeNode.fillColor = [[UIColor blackColor] colorWithAlphaComponent:kHighlightedAlpha];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  _shapeNode.fillColor = [[UIColor blackColor] colorWithAlphaComponent:kNormalAlpha];

  [self invokeTargets];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  _shapeNode.fillColor = [[UIColor blackColor] colorWithAlphaComponent:kNormalAlpha];
}

@end
