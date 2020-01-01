#import <UIKit/UIKit.h>

@interface ACUILinkButton : UIButton
- (id)initWithText:(id)arg1 target:(id)arg2 action:(SEL)arg3;
@end

@interface PSSpecifier : NSObject
+ (id)groupSpecifierWithHeader:(NSString *)header footer:(NSString *)footer;
+ (id)groupSpecifierWithHeader:(NSString *)header footer:(NSString *)footer linkButtons:(NSArray<ACUILinkButton *> *)linkButtons;
@end

@interface PSListController : UIViewController {
    NSArray * _specifiers;
}
- (NSArray *)loadSpecifiersFromPlistName:(NSString *)plistName target:(id)target;
@end