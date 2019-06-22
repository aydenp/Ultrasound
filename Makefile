# TARGET = simulator:clang::11.0
# ARCHS = x86_64
TARGET=iphone::11.2:11.0
ARCHS = arm64 arm64e
DEBUG = 0
GO_EASY_ON_ME = 1
PACKAGE_VERSION = 1.2.9

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Ultrasound
$(TWEAK_NAME)_FILES = $(wildcard *.m) Tweak.xm
$(TWEAK_NAME)_FRAMEWORKS = UIKit
$(TWEAK_NAME)_LDFLAGS += -F./
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
ifeq ($(USE_DDSETTINGS),1)
	SUBPROJECTS += DDSettings
else
	SUBPROJECTS += Settings-Stub
endif
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"

internal-stage::
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -name '*.DS_Store' -type f -delete$(ECHO_END)

ifneq (,$(filter x86_64 i386,$(ARCHS)))
setup:: clean all
	@rm -f /opt/simject/$(TWEAK_NAME).dylib
	@cp -v $(THEOS_OBJ_DIR)/$(TWEAK_NAME).dylib /opt/simject/$(TWEAK_NAME).dylib
	@cp -v $(PWD)/$(TWEAK_NAME).plist /opt/simject
endif
