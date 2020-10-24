
maccat_BIN_DIR = $(TOP)/sdks/out/maccat-bin
maccat_PKG_CONFIG_DIR = $(TOP)/sdks/out/maccat-pkgconfig
maccat_LIBS_DIR = $(TOP)/sdks/out/maccat-libs
maccat_TPN_DIR = $(TOP)/sdks/out/maccat-tpn
maccat_MONO_VERSION = $(TOP)/sdks/out/maccat-mono-version.txt

maccat_ARCHIVE += maccat-bin maccat-pkgconfig maccat-libs maccat-tpn maccat-mono-version.txt
ADDITIONAL_PACKAGE_DEPS += $(maccat_BIN_DIR) $(maccat_PKG_CONFIG_DIR) $(maccat_LIBS_DIR) $(maccat_TPN_DIR) $(maccat_MONO_VERSION)

##
# Parameters
#  $(1): target
#  $(2): host arch
#  $(3): xcode dir
define MacTemplate

maccat_$(1)_PLATFORM_BIN=$(3)/Toolchains/XcodeDefault.xctoolchain/usr/bin

_maccat-$(1)_CC=$$(CCACHE) $$(maccat_$(1)_PLATFORM_BIN)/clang
_maccat-$(1)_CXX=$$(CCACHE) $$(maccat_$(1)_PLATFORM_BIN)/clang++

_maccat-$(1)_AC_VARS= \
	ac_cv_func_fstatat=no \
	ac_cv_func_readlinkat=no \
	ac_cv_func_futimens=no \
	ac_cv_func_utimensat=no

_maccat-$(1)_CFLAGS= \
	$$(maccat-$(1)_SYSROOT) \
	-arch $(2)

_maccat-$(1)_CXXFLAGS= \
	$$(maccat-$(1)_SYSROOT) \
	-arch $(2)

_maccat-$(1)_CPPFLAGS=

_maccat-$(1)_LDFLAGS= \
	-Wl,-no_weak_imports

_maccat-$(1)_CONFIGURE_FLAGS= \
	--disable-boehm \
	--disable-btls \
	--disable-iconv \
	--disable-mcs-build \
	--disable-nls \
	--enable-maintainer-mode \
	--with-glib=embedded \
	--with-mcs-docs=no

.stamp-maccat-$(1)-toolchain:
	touch $$@

$$(eval $$(call RuntimeTemplate,maccat,$(1),$(2)-apple-darwin10,yes))

endef

maccat-mac64_SYSROOT=-isysroot $(XCODE_DIR)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX$(MACOS_VERSION).sdk -mmacosx-version-min=$(MACOS_VERSION_MIN)

$(eval $(call MacTemplate,mac64,x86_64,$(XCODE_DIR)))

$(eval $(call BclTemplate,maccat,xammac xammac_net_4_5,xammac xammac_net_4_5))

$(maccat_BIN_DIR): package-maccat-mac64
	rm -rf $(maccat_BIN_DIR)
	mkdir -p $(maccat_BIN_DIR)

	cp $(TOP)/sdks/out/maccat-mac64-$(CONFIGURATION)/bin/mono-sgen $(maccat_BIN_DIR)/mono-sgen

$(maccat_PKG_CONFIG_DIR): package-maccat-mac64
	rm -rf $(maccat_PKG_CONFIG_DIR)
	mkdir -p $(maccat_PKG_CONFIG_DIR)

	cp $(TOP)/sdks/builds/maccat-mac64-$(CONFIGURATION)/data/mono-2.pc $(maccat_PKG_CONFIG_DIR)

$(maccat_LIBS_DIR): package-maccat-mac64
	rm -rf $(maccat_LIBS_DIR)
	mkdir -p $(maccat_LIBS_DIR)

	cp $(TOP)/sdks/out/maccat-mac64-$(CONFIGURATION)/lib/libmonosgen-2.0.dylib        $(maccat_LIBS_DIR)/libmonosgen-2.0.dylib
	cp $(TOP)/sdks/out/maccat-mac64-$(CONFIGURATION)/lib/libmono-native-compat.dylib  $(maccat_LIBS_DIR)/libmono-native-compat.dylib
	cp $(TOP)/sdks/out/maccat-mac64-$(CONFIGURATION)/lib/libmono-native-unified.dylib $(maccat_LIBS_DIR)/libmono-native-unified.dylib
	cp $(TOP)/sdks/out/maccat-mac64-$(CONFIGURATION)/lib/libMonoPosixHelper.dylib     $(maccat_LIBS_DIR)/libMonoPosixHelper.dylib
	cp $(TOP)/sdks/out/maccat-mac64-$(CONFIGURATION)/lib/libmonosgen-2.0.a            $(maccat_LIBS_DIR)/libmonosgen-2.0.a
	cp $(TOP)/sdks/out/maccat-mac64-$(CONFIGURATION)/lib/libmono-native-compat.a      $(maccat_LIBS_DIR)/libmono-native-compat.a
	cp $(TOP)/sdks/out/maccat-mac64-$(CONFIGURATION)/lib/libmono-native-unified.a     $(maccat_LIBS_DIR)/libmono-native-unified.a
	cp $(TOP)/sdks/out/maccat-mac64-$(CONFIGURATION)/lib/libmono-profiler-log.a       $(maccat_LIBS_DIR)/libmono-profiler-log.a

	$(maccat_mac64_PLATFORM_BIN)/install_name_tool -id @rpath/libmonosgen-2.0.dylib        $(maccat_LIBS_DIR)/libmonosgen-2.0.dylib
	$(maccat_mac64_PLATFORM_BIN)/install_name_tool -id @rpath/libmono-native-compat.dylib  $(maccat_LIBS_DIR)/libmono-native-compat.dylib
	$(maccat_mac64_PLATFORM_BIN)/install_name_tool -id @rpath/libmono-native-unified.dylib $(maccat_LIBS_DIR)/libmono-native-unified.dylib
	$(maccat_mac64_PLATFORM_BIN)/install_name_tool -id @rpath/libMonoPosixHelper.dylib     $(maccat_LIBS_DIR)/libMonoPosixHelper.dylib

$(maccat_MONO_VERSION): $(TOP)/configure.ac
	mkdir -p $(dir $(maccat_MONO_VERSION))
	grep AC_INIT $(TOP)/configure.ac | sed -e 's/.*\[//' -e 's/\].*//' > $@

$(maccat_TPN_DIR)/LICENSE:
	mkdir -p $(maccat_TPN_DIR)
	cd $(TOP) && rsync -r --include='THIRD-PARTY-NOTICES.TXT' --include='license.txt' --include='License.txt' --include='LICENSE' --include='LICENSE.txt' --include='LICENSE.TXT' --include='COPYRIGHT.regex' --include='*/' --exclude="*" --prune-empty-dirs . $(maccat_TPN_DIR)

$(maccat_TPN_DIR): $(maccat_TPN_DIR)/LICENSE
