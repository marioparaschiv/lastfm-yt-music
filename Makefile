THEOS_PACKAGE_SCHEME=rootless
ARCHS := arm64 arm64e
TARGET := iphone:clang:latest:7.0
INSTALL_TARGET_PROCESSES = YouTubeMusic

include $(THEOS)/makefiles/common.mk

LASTFM_API_KEY = xxx
LASTFM_API_SECRET = xxx
TWEAK_NAME = LastFMYouTubeMusic

$(TWEAK_NAME)_FILES = $(shell find sources -name "*.x*")
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -DAPI_KEY=@\"$(LASTFM_API_KEY)\" -DAPI_SECRET=@\"$(LASTFM_API_SECRET)\"
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation CydiaSubstrate

include $(THEOS_MAKE_PATH)/tweak.mk
