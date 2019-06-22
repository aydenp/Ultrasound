ARCHS = arm64 arm64e
TARGET = iphone::9.3:9.0
GO_EASY_ON_ME = 1

TWEAK_NAME = Ultrasound

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = $(TWEAK_NAME)OSSSettings
$(BUNDLE_NAME)_CFLAGS = -fobjc-arc
$(BUNDLE_NAME)_FILES = $(wildcard *.mm)
$(BUNDLE_NAME)_INSTALL_PATH = /Library/PreferenceBundles
$(BUNDLE_NAME)_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)cp -R ../DDSettings-Resources/ $(THEOS_STAGING_DIR)/Library/PreferenceBundles/$(BUNDLE_NAME).bundle$(ECHO_END)
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/$(TWEAK_NAME).plist$(ECHO_END)