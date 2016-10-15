#import "Slider.h"

#import "SKNode+Control.h"

@implementation Slider {
  SKLabelNode *_label;
  SKShapeNode *_minTrack;
  SKShapeNode *_maxTrack;
  SKShapeNode *_thumb;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _scale = 1;
    _currentValue = -1;

    self.userInteractionEnabled = YES;

    _label = [[SKLabelNode alloc] init];
    _label.fontColor = [SKColor grayColor];
    _label.fontName = @"Helvetica-Bold";
    _label.fontSize = 12;
    _label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    _label.position = CGPointMake(-100, 16);
    [self addChild:_label];

    _maxTrack = [[SKShapeNode alloc] init];
    UIBezierPath *line = [UIBezierPath bezierPath];
    [line moveToPoint:CGPointMake(-100, 0)];
    [line addLineToPoint:CGPointMake(100, 0)];
    _maxTrack.path = line.CGPath;
    _maxTrack.strokeColor = [[SKColor lightGrayColor] colorWithAlphaComponent:0.8];
    _maxTrack.lineWidth = 2.0;
    _maxTrack.lineCap = kCGLineCapRound;
    [self addChild:_maxTrack];

    _minTrack = [[SKShapeNode alloc] init];
    _minTrack.strokeColor = [SKColor yellowColor];
    _minTrack.lineWidth = 2.0;
    _minTrack.lineCap = kCGLineCapRound;
    [self addChild:_minTrack];

    _thumb = [SKShapeNode shapeNodeWithCircleOfRadius:8];
    _thumb.fillColor = [SKColor yellowColor];
    _thumb.lineWidth = 0;
    [self addChild:_thumb];
  }
  return self;
}

- (void)setColor:(SKColor *)color {
  _color = color;

  _minTrack.strokeColor = [color colorWithAlphaComponent:0.8];
  _thumb.fillColor = color;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [super touchesBegan:touches withEvent:event];

  CGPoint point = [[touches anyObject] locationInNode:self];
  CGFloat clampedX = MAX(0, MIN(200, point.x + 100));
  CGFloat newValue = _minValue + (_maxValue - _minValue) * clampedX / 200;
  [self setCurrentValue:newValue sender:self];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [super touchesMoved:touches withEvent:event];


  CGPoint point = [[touches anyObject] locationInNode:self];
  CGFloat clampedX = MAX(0, MIN(200, point.x + 100));
  CGFloat newValue = _minValue + (_maxValue - _minValue) * clampedX / 200;
  [self setCurrentValue:newValue sender:self];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [super touchesEnded:touches withEvent:event];

  CGPoint point = [[touches anyObject] locationInNode:self];
  CGFloat clampedX = MAX(0, MIN(200, point.x + 100));
  CGFloat newValue = _minValue + (_maxValue - _minValue) * clampedX / 200;
  [self setCurrentValue:newValue sender:self];
}

#pragma mark Private Methods

- (void)setCurrentValue:(CGFloat)currentValue {
  [self setCurrentValue:currentValue sender:nil];
}

- (void)setCurrentValue:(CGFloat)currentValue sender:(id)sender {
  currentValue = round(currentValue * _scale) / _scale;
  if (_currentValue == currentValue) {
    return;
  }

  _currentValue = currentValue;

  CGFloat clampedX = (currentValue - _minValue) * 200 / (_maxValue - _minValue);
  _thumb.position = CGPointMake(clampedX - 100, 0);
  UIBezierPath *line = [UIBezierPath bezierPath];
  [line moveToPoint:CGPointMake(-100, 0)];
  [line addLineToPoint:CGPointMake(clampedX - 100, 0)];
  _minTrack.path = line.CGPath;

  _label.text = [NSString stringWithFormat:@"%@: %@", _title, @(currentValue)];

  if (sender == self) {
    [self invokeTargets];
  }
}

@end
