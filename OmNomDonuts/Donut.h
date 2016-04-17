//
//  Donut.h
//  OmNomDonuts
//
//  Created by John Z Wu on 5/18/14.
//
//

@protocol Donut <NSObject>

@property(nonatomic, readonly) NSInteger value;
@property(nonatomic, readonly) NSTimeInterval contractDuration;
@property(nonatomic, assign) BOOL hit;

@end