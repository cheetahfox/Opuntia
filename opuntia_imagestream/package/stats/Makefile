# stats

include $(TOPDIR)/rules.mk

PKG_NAME:=stats
PKG_VERSION:=3.5
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

TARGET_CFLAGS += -Wno-error=implicit-function-declaration -Wno-error=implicit-int -Wno-error=int-conversion
TARGET_CFLAGS += -DNR_CPUS=32

define Package/stats
  SECTION:=net
  CATEGORY:=ImageStream
  TITLE:=Stats
  DEPENDS:=+libncurses
  DEFAULT:=y
endef

define Package/stats/description
ImageStream's Network Stats Utility
endef

define Package/stats/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/stats $(1)/bin
endef

$(eval $(call BuildPackage,stats))
