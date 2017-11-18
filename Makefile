include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk


RUBY_PKG_LIBVER:=2.2

PKG_NAME:=ruby-eventmachine
PKG_SHORT_NAME:=eventmachine
PKG_RELEASE:=1
PKG_LIBVER:=1.2.5
PKG_REV:=dcec4a7890d2cec53cbf397e9561ad7ef0f48b21
PKG_VERSION:=$(PKG_LIBVER)

PKG_SOURCE:=$(PKG_NAME).tar.gz
PKG_SOURCE_URL:=git://github.com/eventmachine/eventmachine.git
PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_PROTO:=git

PKG_BUILD_DEPENDS:=
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/ruby-eventmachine
	SUBMENU:=Ruby
	SECTION:=lang
	CATEGORY:=Languages
	DEPENDS:=+ruby-socket +libstdcpp +libc +libgcc +libopenssl
	TITLE:=Ruby eventmachine gem
endef

RUBY:= \
	$(STAGING_DIR_HOST)/bin/ruby -I $(STAGING_DIR_HOST)/share/ri \


define Package/ruby-eventmachine/description
	This package contains the ruby eventmachine gem.
endef

define Build/Configure/eventmachine
	(cd $(PKG_BUILD_DIR)/ext; \
	$(RUBY) extconf.rb; \
	);
endef

define Build/Compile/eventmachine
	$(MAKE_VARS) \
	$(MAKE) -C $(PKG_BUILD_DIR)/ext \
	$(MAKE_FLAGS) \
	$(1);
	$(CP) $(PKG_BUILD_DIR)/ext/*.so $(PKG_BUILD_DIR)/lib/
endef

define Build/Configure/fastfilereader
	(cd $(PKG_BUILD_DIR)/ext/fastfilereader; \
	$(RUBY) extconf.rb; \
	);
endef

define Build/Compile/fastfilereader
	$(MAKE_VARS) \
	$(MAKE) -C $(PKG_BUILD_DIR)/ext/fastfilereader \
	$(MAKE_FLAGS) \
	$(1);
	$(CP) $(PKG_BUILD_DIR)/ext/fastfilereader/*.so $(PKG_BUILD_DIR)/lib/
endef

define Build/Configure
	$(call Build/Configure/eventmachine)
	$(call Build/Configure/fastfilereader)
endef

# 1337hack Makefiles here
define Build/Compile
	$(SED) 's/-fstack-protector//' $(PKG_BUILD_DIR)/ext/fastfilereader/Makefile
	$(SED) '17s/host.*/target-mips_34kc_uClibc-0.9.33.2\/usr\/include\/ruby-2.2\/mips-linux-gnu/' $(PKG_BUILD_DIR)/ext/fastfilereader/Makefile
	$(call Build/Compile/fastfilereader)
	$(SED) 's/-fstack-protector//' $(PKG_BUILD_DIR)/ext/Makefile
	$(SED) '17s/host.*/target-mips_34kc_uClibc-0.9.33.2\/usr\/include\/ruby-2.2\/mips-linux-gnu/' $(PKG_BUILD_DIR)/ext/Makefile
	$(call Build/Compile/eventmachine)
endef

define Package/ruby-eventmachine/install
	$(INSTALL_DIR) $(1)/usr/lib/ruby/$(RUBY_PKG_LIBVER)/mips-linux-gnu
	$(CP) $(PKG_BUILD_DIR)/lib/eventmachine.rb $(1)/usr/lib/ruby/$(RUBY_PKG_LIBVER)/
	$(CP) $(PKG_BUILD_DIR)/lib/em $(1)/usr/lib/ruby/$(RUBY_PKG_LIBVER)/
	$(CP) $(PKG_BUILD_DIR)/lib/*.so $(1)/usr/lib/ruby/$(RUBY_PKG_LIBVER)/mips-linux-gnu
endef

$(eval $(call BuildPackage,ruby-eventmachine,+libopenssl))
