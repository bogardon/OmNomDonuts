//
//  MenuButtonNode.m
//  OmNomDonuts
//
//  Created by jzw on 6/12/16.
//
//

#import "MenuButtonNode.h"

#import "SKNode+Control.h"

@implementation MenuButtonNode

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [self invokeTargets];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

}

@end
