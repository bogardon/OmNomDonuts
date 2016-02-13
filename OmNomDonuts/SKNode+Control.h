//
//  SKNode+Control.h
//  OmNomDonuts
//
//  Created by jzw on 2/13/16.
//
//

#import <SpriteKit/SpriteKit.h>

@interface SKNode (Control)

- (void)addTarget:(id)target selector:(SEL)selector;

- (void)invokeTargets;

@end
