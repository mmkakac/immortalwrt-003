#
# Copyright (C) 2020-2022 HandsomeMod Project
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk


PKG_NAME:=android-tools
PKG_VERSION:=4.2.2

# 本地源码：随仓库 ufi001c/vendor/android-tools 备份（原 lkiuyu/android-tools @ 6cea387），不再联网下载
USE_SOURCE_DIR:=$(TOPDIR)/ufi001c/vendor/android-tools
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_MAINTAINER:=HandsomeYingyan <handsomeyingyan@gmail.com>

include $(INCLUDE_DIR)/package.mk


define Package/android-tools/default
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Android Debug Tools
  URL:=http://tools.android.com/
  DEPENDS:=+zlib +libopenssl +libpthread +kmod-usb-gadget-functionfs
endef

define Package/$(PKG_NAME)/Default/description
 Android Debug Bridge (adb) is a versatile command line tool that lets you communicate with an emulator instance or connected Android-powered device.
endef


define Package/$(PKG_NAME)-adbd
$(call Package/$(PKG_NAME)/default)
	TITLE+= - adbd
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		TARGET=Linux \
		CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		-f $(PKG_BUILD_DIR)/adbd.mk
endef

define Package/$(PKG_NAME)-adbd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/adbd $(1)/usr/bin/
	$(INSTALL_BIN) ./files/adbd.init $(1)/etc/init.d/adbd
	$(INSTALL_DATA) ./files/adb_profile $(1)/etc/
	$(INSTALL_DATA) ./files/adb_disable $(1)/etc/uci-defaults
endef

$(eval $(call BuildPackage,$(PKG_NAME)-adbd))
