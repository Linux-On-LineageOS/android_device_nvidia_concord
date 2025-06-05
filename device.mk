#
# Copyright (C) 2022 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Only include Shield apps for first party targets
ifneq ($(filter $(word 2,$(subst _, ,$(TARGET_PRODUCT))), concord concord_tab),)
include device/nvidia/shield-common/shield.mk
endif

TARGET_REFERENCE_DEVICE ?= concord
TARGET_TEGRA_VARIANT    ?= common

TARGET_TEGRA_MODELS := $(shell awk -F, '/tegra_init::devices/{ f = 1; next } /};/{ f = 0 } f{ gsub(/"/, "", $$3); gsub(/ /, "", $$3); print $$3 }' device/nvidia/$(TARGET_REFERENCE_DEVICE)/init/init_$(TARGET_REFERENCE_DEVICE).cpp |sort |uniq)
TARGET_TEGRA_VARIANTS := $(shell awk -F, '/tegra_init::devices/{ f = 1; next } /};/{ f = 0 } f{ gsub(/"/, "", $$2); gsub(/ /, "", $$2); print $$2 }' device/nvidia/$(TARGET_REFERENCE_DEVICE)/init/init_$(TARGET_REFERENCE_DEVICE).cpp |sort |uniq)

TARGET_KERNEL_VERSION ?= 5.10
TARGET_TEGRA_BOOTCTRL ?= efi
TARGET_TEGRA_BT       ?= btlinux
TARGET_TEGRA_CAMERA   ?= rel-shield-r
TARGET_TEGRA_HEALTH   ?= nobattery
TARGET_TEGRA_KEYSTORE ?= software
TARGET_TEGRA_LIGHT    ?= lineage
TARGET_TEGRA_PMODEL   ?= r36
TARGET_TEGRA_THERMAL  ?= lineage
TARGET_TEGRA_WIDEVINE ?= rel-shield-r
TARGET_TEGRA_WIFI     ?= rtl8822ce

include device/nvidia/t234-common/t234.mk

# System properties
include device/nvidia/concord/system_prop.mk

PRODUCT_CHARACTERISTICS   := tv
PRODUCT_AAPT_PREBUILT_DPI := xxhdpi xhdpi hdpi mdpi hdpi tvdpi
PRODUCT_AAPT_PREF_CONFIG  := xhdpi

PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := true

$(call inherit-product, frameworks/native/build/tablet-10in-xhdpi-2048-dalvik-heap.mk)

PRODUCT_USE_DYNAMIC_PARTITIONS := true

include device/nvidia/concord/vendor/concord-vendor.mk

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += device/nvidia/concord

# Init related
PRODUCT_COPY_FILES += \
    $(foreach model,$(TARGET_TEGRA_MODELS),device/nvidia/concord/initfiles/fstab.concord:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.$(model)) \
    $(foreach model,$(TARGET_TEGRA_MODELS),device/nvidia/concord/initfiles/fstab.concord:$(TARGET_COPY_OUT_RAMDISK)/fstab.$(model)) \
    $(foreach model,$(TARGET_TEGRA_MODELS),device/nvidia/concord/initfiles/init.concord.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.$(model).rc) \
    $(foreach model,$(TARGET_TEGRA_MODELS),device/nvidia/concord/initfiles/init.recovery.concord.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.$(model).rc) \
    $(foreach model,$(TARGET_TEGRA_MODELS),device/nvidia/concord/initfiles/power.concord.rc:$(TARGET_COPY_OUT_ODM)/etc/power.$(model).rc) \
    device/nvidia/concord/initfiles/init.concord_common.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.concord_common.rc

# Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.audio.low_latency.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.low_latency.xml \
    frameworks/native/data/etc/android.hardware.ethernet.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.ethernet.xml

# ATV specific stuff
ifeq ($(PRODUCT_IS_ATV),true)
    PRODUCT_PACKAGES += \
        android.hardware.tv.input@1.0-impl
endif

# Audio
ifneq ($(filter rel-shield-r, $(TARGET_TEGRA_AUDIO)),)
PRODUCT_PACKAGES += \
    audio_effects.xml \
    audio_policy_configuration.xml \
    nvaudio_conf.xml \
    nvaudio_fx.xml
endif

# fastbootd
PRODUCT_PACKAGES += \
    fastbootd

# Fingerprint override
PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildFingerprint=NVIDIA/concord/concord:11/RQ1A.210105.003/13961456_3871.0251:user/release-keys

# Kernel
ifneq ($(TARGET_PREBUILT_KERNEL),)
TARGET_FORCE_PREBUILT_KERNEL := true
endif

# Loadable kernel modules
PRODUCT_PACKAGES += \
    lkm_loader
PRODUCT_COPY_FILES += \
    device/nvidia/tegra-common/initfiles/init.lkm.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.lkm.rc

# Media config
ifneq ($(filter rel-shield-r, $(TARGET_TEGRA_OMX)),)
PRODUCT_PACKAGES += \
    media_codecs.xml \
    media_codecs_performance.xml \
    media_profiles_V1_0.xml \
    enctune.conf
endif

# PHS
ifneq ($(TARGET_TEGRA_PHS),)
PRODUCT_COPY_FILES += \
    device/nvidia/concord/nvphs/nvphsd.conf.t234:$(TARGET_COPY_OUT_ODM)/etc/nvphsd.conf
endif

# PModel
ifneq ($(TARGET_TEGRA_PMODEL),)
PRODUCT_COPY_FILES += \
    device/nvidia/concord/nvpmodel/nvpmodel_p3701_0000.conf:$(TARGET_COPY_OUT_ODM)/etc/nvpmodel_p3701_0000.conf \
    device/nvidia/concord/nvpmodel/nvpmodel_p3701_0004.conf:$(TARGET_COPY_OUT_ODM)/etc/nvpmodel_p3701_0004.conf \
    device/nvidia/concord/nvpmodel/nvpmodel_p3767_0000_super.conf:$(TARGET_COPY_OUT_ODM)/etc/nvpmodel_p3767_0000_super.conf \
    device/nvidia/concord/nvpmodel/nvpmodel_p3767_0001_super.conf:$(TARGET_COPY_OUT_ODM)/etc/nvpmodel_p3767_0001_super.conf \
    device/nvidia/concord/nvpmodel/nvpmodel_p3767_0003_super.conf:$(TARGET_COPY_OUT_ODM)/etc/nvpmodel_p3767_0003_super.conf \
    device/nvidia/concord/nvpmodel/nvpmodel_p3767_0004_super.conf:$(TARGET_COPY_OUT_ODM)/etc/nvpmodel_p3767_0004_super.conf
endif

# Thermal
ifneq ($(TARGET_TEGRA_THERMAL),)
PRODUCT_COPY_FILES += \
    $(foreach variant,$(TARGET_TEGRA_VARIANTS),device/nvidia/concord/thermal/thermalhal.$(variant).xml:$(TARGET_COPY_OUT_VENDOR)/etc/thermalhal.$(variant).xml)
endif

# Updater
ifneq ($(TARGET_TEGRA_BOOTCTRL),)
AB_OTA_PARTITIONS += \
    boot \
    product \
    recovery \
    system \
    vbmeta \
    vbmeta_system \
    vendor \
    vendor_boot \
    odm
ifeq ($(TARGET_TEGRA_BOOTCTRL),efi)
# Bootloader update not supported
endif
endif
$(call inherit-product, vendor/lindroid/lindroid.mk)
