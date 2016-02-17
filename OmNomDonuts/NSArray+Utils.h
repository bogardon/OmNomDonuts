//
//  NSArray+Utils.h
//  OmNomDonuts
//
//  Created by jzw on 2/16/16.
//
//

#import <Foundation/Foundation.h>

typedef BOOL(^FilterBlock)(id object);

@interface NSArray (Utils)

- (NSArray *)filteredArrayWithBlock:(FilterBlock)block;

@end
