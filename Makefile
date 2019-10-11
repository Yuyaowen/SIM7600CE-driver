include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

PKG_NAME:=sim7600ce
PKG_RELEASE:=1

define KernelPackage/$(PKG_NAME)
	SUBMENU:=Network Devices
	DEPENDS:=+kmod-usb-core
	DEPENDS:=+kmod-usb-net
	TITLE:=Add 4G SIM7600CE support
	AUTOLOAD:=$(call AutoLoad,81,$(PKG_NAME))
	FILES:=$(PKG_BUILD_DIR)/$(PKG_NAME).$(LINUX_KMOD_SUFFIX)
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) -R ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
	$(MAKE) -C "$(LINUX_DIR)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		ARCH="$(LINUX_KARCH)" \
		SUBDIRS="$(PKG_BUILD_DIR)" \
		EXTRA_CFLAGS="-g $(BUILDFLAGS)" \
		modules
endef

$(eval $(call KernelPackage,$(PKG_NAME)))
