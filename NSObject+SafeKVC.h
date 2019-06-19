#import <Foundation/Foundation.h>

@interface NSObject (SafeKVC)
- (id)safeValueForKey:(NSString *)key;
- (void)safelySetValue:(id)obj forKey:(NSString *)key;
@end