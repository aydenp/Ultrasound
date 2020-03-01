#import <UIKit/UIKit.h>
#import "Headers.h"

@interface UltrasoundSettingsController : PSListController
@end

@implementation UltrasoundSettingsController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"Ultrasound (Open Source Edition)";
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *specifiers = [[self loadSpecifiersFromPlistName:@"Ultrasound" target:self] mutableCopy];
		PSSpecifier *ossSpecifier = [PSSpecifier groupSpecifierWithHeader:@"Open Source"
													footer:@"It looks like you're using open source Ultrasound on your device.\n\nThat's cool, but consider purchasing Ultrasound from Dynastic Repo to support my continued maintenance of Ultrasound and future projects.\n\nWhile I enjoy making tweaks, they take up a lot of time — time that I could be doing paid work, so please consider purchasing Ultrasound so I can continue to make tweaks."
													linkButtons:@[[[NSClassFromString(@"ACUILinkButton") alloc] initWithText:@"Get Ultrasound from Dynastic Repo" target:self action:@selector(getUltrasound)], [[NSClassFromString(@"ACUILinkButton") alloc] initWithText:@"Follow me on Twitter" target:self action:@selector(followOnTwitter)]]];
		[specifiers insertObject:ossSpecifier atIndex:0];
		_specifiers = specifiers;
	}
	return _specifiers;
}

- (void)getUltrasound {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://repo.dynastic.co/package/ultrasound"] options:@{} completionHandler:nil];
}

- (void)followOnTwitter {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/intent/follow?screen_name=aydenpanhuyzen"] options:@{} completionHandler:nil];
}

@end
