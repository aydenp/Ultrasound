#import <UIKit/UIKit.h>

// why do you do this??? simulator has a different root.
#define ControlCenterModulesRoot [[[[[NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/ControlCenterUIKit.framework"/*Identifier:@"com.apple.ControlCenterUIKit"*/].bundleURL URLByDeletingLastPathComponent] URLByDeletingLastPathComponent] URLByAppendingPathComponent:@"ControlCenter"] URLByAppendingPathComponent:@"Bundles"]

@interface CCUICAPackageDescription : NSObject
+ (instancetype)descriptionForPackageNamed:(NSString *)name inBundle:(NSBundle *)bundle;
@end

@interface CCUICAPackageView : UIView
@property (nonatomic,retain) CCUICAPackageDescription *packageDescription;
- (void)setStateName:(NSString *)name;
@end
