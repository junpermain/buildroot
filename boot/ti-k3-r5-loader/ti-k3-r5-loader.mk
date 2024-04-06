################################################################################
#
# ti-k3-r5-loader
#
################################################################################

TI_K3_R5_LOADER_VERSION = $(call qstrip,$(BR2_TARGET_TI_K3_R5_LOADER_VERSION))

ifeq ($(BR2_TARGET_TI_K3_R5_LOADER_CUSTOM_TARBALL),y)
# Handle custom U-Boot tarballs as specified by the configuration
TI_K3_R5_LOADER_TARBALL = $(call qstrip,$(BR2_TARGET_TI_K3_R5_LOADER_CUSTOM_TARBALL_LOCATION))
TI_K3_R5_LOADER_SITE = $(patsubst %/,%,$(dir $(TI_K3_R5_LOADER_TARBALL)))
TI_K3_R5_LOADER_SOURCE = $(notdir $(TI_K3_R5_LOADER_TARBALL))
else ifeq ($(BR2_TARGET_TI_K3_R5_LOADER_CUSTOM_GIT),y)
TI_K3_R5_LOADER_SITE = $(call qstrip,$(BR2_TARGET_TI_K3_R5_LOADER_CUSTOM_REPO_URL))
TI_K3_R5_LOADER_SITE_METHOD = git
else ifeq ($(BR2_TARGET_TI_K3_R5_LOADER_CUSTOM_HG),y)
TI_K3_R5_LOADER_SITE = $(call qstrip,$(BR2_TARGET_TI_K3_R5_LOADER_CUSTOM_REPO_URL))
TI_K3_R5_LOADER_SITE_METHOD = hg
else ifeq ($(BR2_TARGET_TI_K3_R5_LOADER_CUSTOM_SVN),y)
TI_K3_R5_LOADER_SITE = $(call qstrip,$(BR2_TARGET_TI_K3_R5_LOADER_CUSTOM_REPO_URL))
TI_K3_R5_LOADER_SITE_METHOD = svn
else
# Handle stable official U-Boot versions
TI_K3_R5_LOADER_SITE = https://ftp.denx.de/pub/u-boot
TI_K3_R5_LOADER_SOURCE = u-boot-$(TI_K3_R5_LOADER_VERSION).tar.bz2
endif

ifeq ($(BR2_TARGET_TI_K3_R5_LOADER)$(BR2_TARGET_TI_K3_R5_LOADER_LATEST_VERSION),y)
BR_NO_CHECK_HASH_FOR += $(TI_K3_R5_LOADER_SOURCE)
endif

TI_K3_R5_LOADER_LICENSE = GPL-2.0+
TI_K3_R5_LOADER_LICENSE_FILES = Licenses/gpl-2.0.txt
TI_K3_R5_LOADER_CPE_ID_VENDOR = denx
TI_K3_R5_LOADER_CPE_ID_PRODUCT = u-boot
TI_K3_R5_LOADER_INSTALL_IMAGES = YES
TI_K3_R5_LOADER_DEPENDENCIES = \
	host-pkgconf \
	$(BR2_MAKE_HOST_DEPENDENCY) \
	host-arm-gnu-toolchain \
	host-openssl

TI_K3_R5_LOADER_MAKE = $(BR2_MAKE)
TI_K3_R5_LOADER_MAKE_ENV = $(TARGET_MAKE_ENV)
TI_K3_R5_LOADER_KCONFIG_DEPENDENCIES = \
	host-arm-gnu-toolchain \
	$(BR2_MAKE_HOST_DEPENDENCY) \
	$(BR2_BISON_HOST_DEPENDENCY) \
	$(BR2_FLEX_HOST_DEPENDENCY)

ifeq ($(BR2_TARGET_TI_K3_R5_LOADER_USE_DEFCONFIG),y)
TI_K3_R5_LOADER_KCONFIG_DEFCONFIG = $(call qstrip,$(BR2_TARGET_TI_K3_R5_LOADER_BOARD_DEFCONFIG))_defconfig
else ifeq ($(BR2_TARGET_TI_K3_R5_LOADER_USE_CUSTOM_CONFIG),y)
TI_K3_R5_LOADER_KCONFIG_FILE = $(call qstrip,$(BR2_TARGET_TI_K3_R5_LOADER_CUSTOM_CONFIG_FILE))
endif # BR2_TARGET_TI_K3_R5_LOADER_USE_DEFCONFIG
TI_K3_R5_LOADER_MAKE_OPTS = \
	CROSS_COMPILE=$(HOST_DIR)/bin/arm-none-eabi- \
	ARCH=arm \
	HOSTCC="$(HOSTCC) $(subst -I/,-isystem /,$(subst -I /,-isystem /,$(HOST_CFLAGS)))" \
	HOSTLDFLAGS="$(HOST_LDFLAGS)"

ifeq ($(BR2_TARGET_TI_K3_R5_LOADER_USE_BINMAN),y)
# https://source.denx.de/u-boot/u-boot/-/blob/v2024.01/tools/buildman/requirements.txt
TI_K3_R5_LOADER_DEPENDENCIES += \
	host-python-jsonschema \
	host-python-pyyaml \
	ti-k3-boot-firmware
# Make sure that all binman requirements are build before ti-k3-r5-loader.
TI_K3_R5_LOADER_DEPENDENCIES += \
	host-python3 \
	host-python-pyelftools \
	host-python-pylibfdt \
	host-python-setuptools
TI_K3_R5_LOADER_MAKE_OPTS += BINMAN_INDIRS=$(BINARIES_DIR)

TI_K3_R5_LOADER_TIBOOT3_BIN = $(call qstrip,$(BR2_TARGET_TI_K3_R5_LOADER_TIBOOT3_BIN))

define TI_K3_R5_LOADER_INSTALL_TIBOOT3_BIN
	cp $(@D)/$(TI_K3_R5_LOADER_TIBOOT3_BIN) $(BINARIES_DIR)/tiboot3.bin
endef

TI_K3_R5_LOADER_SYSFW_ITB = $(call qstrip,$(BR2_TARGET_TI_K3_R5_LOADER_SYSFW_ITB))

# sysfw*.itb are only generated for Split binary based Boot Flow (eg: am65, j721e).
# So, if sysfw.itb symlink exist we must copy it or the custom sysfw.itb.
define TI_K3_R5_LOADER_INSTALL_SWSFW_ITB
	if test -e $(@D)/sysfw.itb ; then \
		cp $(@D)/$(TI_K3_R5_LOADER_SYSFW_ITB) $(BINARIES_DIR)/sysfw.itb ; \
	fi
endef

endif # BR2_TARGET_TI_K3_R5_LOADER_USE_BINMAN

define TI_K3_R5_LOADER_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) $(TI_K3_R5_LOADER_MAKE) -C $(@D) $(TI_K3_R5_LOADER_MAKE_OPTS)
endef

define TI_K3_R5_LOADER_INSTALL_IMAGES_CMDS
	cp $(@D)/spl/u-boot-spl.bin $(BINARIES_DIR)/r5-u-boot-spl.bin
	$(TI_K3_R5_LOADER_INSTALL_TIBOOT3_BIN)
	$(TI_K3_R5_LOADER_INSTALL_SWSFW_ITB)
endef

# Checks to give errors that the user can understand
# Must be before we call to kconfig-package
ifeq ($(BR2_TARGET_TI_K3_R5_LOADER)$(BR_BUILDING),yy)

ifeq ($(TI_K3_R5_LOADER_TIBOOT3_BIN),)
$(error No custom tiboot3 name specified, check your BR2_TARGET_TI_K3_R5_LOADER_TIBOOT3_BIN setting)
endif

ifeq ($(TI_K3_R5_LOADER_SYSFW_ITB),)
$(error No custom sysfw name specified, check your BR2_TARGET_TI_K3_R5_LOADER_SYSFW_ITB setting)
endif

endif # BR_BUILDING

$(eval $(kconfig-package))
