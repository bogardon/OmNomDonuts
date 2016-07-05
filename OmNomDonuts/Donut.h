@protocol Donut <NSObject>

@property(nonatomic, readonly) NSInteger value;
@property(nonatomic, readonly) NSTimeInterval contractDuration;
@property(nonatomic, assign) BOOL hit;

@end