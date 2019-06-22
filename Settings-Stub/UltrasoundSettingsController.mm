#import <UIKit/UIKit.h>

@interface PSListController : UIViewController {
    NSArray * _specifiers;
}
- (NSArray *)loadSpecifiersFromPlistName:(NSString *)plistName target:(id)target;
@end

@interface UltrasoundSettingsController : PSListController
@end

@implementation UltrasoundSettingsController

- (NSArray *)specifiers {
	if (_specifiers == nil) _specifiers = [self loadSpecifiersFromPlistName:@"Ultrasound" target:self];
	return _specifiers;
}

@end