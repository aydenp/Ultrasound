#import "NSObject+SafeKVC.h"

@implementation NSObject (SafeKVC)

- (id)safeValueForKey:(NSString *)key {
    @try {
        return [self valueForKey:key];
    } @catch (NSException *e) {
        return nil;
    }
}

- (void)safelySetValue:(id)val forKey:(NSString *)key {
    @try {
        return [self setValue:val forKey:key];
    } @catch (NSException *e) {}
}

@end