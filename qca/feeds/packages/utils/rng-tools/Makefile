#
# Copyright (C) 2011-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=rng-tools
PKG_VERSION:=5
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/gkernel/rng-tools/$(PKG_VERSION)/
PKG_MD5SUM:=6726cdc6fae1f5122463f24ae980dd68
PKG_LICENSE:=GPLv2
PKG_MAINTAINER:=Hannu Nyman <hannu.nyman@iki.fi>

PKG_FIXUP:=autoreconf

PKG_BUILD_DEPENDS:=USE_UCLIBC:argp-standalone

include $(INCLUDE_DIR)/package.mk

define Package/rng-tools
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Daemon for adding entropy to kernel entropy pool
  URL:=http://sourceforge.net/projects/gkernel/
endef

ifdef CONFIG_USE_UCLIBC
CONFIGURE_VARS += \
    LIBS="-largp"
endif

CONFIGURE_ARGS += \
	--without-libgcrypt

EXTRA_CFLAGS := -DRNG_TEST_PRIV

ifneq ($(CONFIG_TARGET_ar71xx),)
EXTRA_CFLAGS += -DENTROPY_FACTOR=5
endif

define Package/rng-tools/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/rngd.init $(1)/etc/init.d/rngd
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/rngtest $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/rngd $(1)/sbin/
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DATA) ./files/rngd.hotplug $(1)/etc/hotplug.d/iface/90-rngd
endef

$(eval $(call BuildPackage,rng-tools))
