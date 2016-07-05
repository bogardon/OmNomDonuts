#import <Foundation/Foundation.h>

typedef BOOL(^FilterBlock)(id object);

@interface NSArray (Utils)

- (NSArray *)filteredArrayWithBlock:(FilterBlock)block;

@end
