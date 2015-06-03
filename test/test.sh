#!/bin/bash

# Find where is this script
D="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# images
CM_IMAGE=$D/cm_revolution-4.4.4-cm11-1433289809.zip-boot.img
ANDROID_IMAGE=$D/revolution-4.2.2-1397040567.zip-boot.img
FFOS_IMAGE=$D/revolution-FFOS_v2.0-1429720398.zip-boot.img

# tools
PACK=${D}/../pack_intel
UNPACK=${D}/../unpack_intel

# testing function
error() {
    echo -e "\n\033[31m\033[1mERROR: $1\033[0m\n"
}
die () {
    error "$1"
    exit 1
}

check_image_unpack() {
    local image=$1
    local kernel=$2
    local ramdisk=$3

    # unpack data
    $UNPACK $image $kernel $ramdisk

    # kernel should be kernel
    file $kernel | grep kernel
    if [ $? -ne 0 ]; then
        die "$image unpack to $kernel is invalid Linux kernel image."
    fi

    # ramdisk should be gzip compressed data
    file $ramdisk | grep gzip
    if [ $? -ne 0 ]; then
        die "$image unpack to $ramdisk is invalid gzip compressed data."
    fi
}

check_image_repack() {
    local image=$1
    local kernel=$2
    local ramdisk=$3
    local valid=$4   # reference for create boot.img (valid image)

    # clear last testing blob
    rm -rf tmp > /dev/null 2>&1
    # repack boot.img
    $PACK $valid $kernel $ramdisk tmp
    # check if the same as original image
    cmp $image tmp
    if [ $? -ne 0 ]; then
        die "$image not the same as repack one."
    fi
}

dummy_image_check() {
    local image=$1
    local kernel=$2
    local ramdisk=$3

    # make sure no samename dummy kernel present
    rm -rf $kernel $ramdisk dummy1 dummy2 > /dev/null 2>&1

    # create dummy kernel/ramdisk
    touch $kernel $ramdisk

    $PACK $image $kernel $ramdisk dummy1
    $UNPACK dummy1  $kernel.tmp $ramdisk.tmp
    $PACK $image  $kernel.tmp $ramdisk.tmp dummy2

    # compare
    cmp dummy1 dummy2
    if [ $? -ne 0 ]; then
        die "dummy kernel/ramdisk test failed (valid image: $image)"
    fi

    # clear all
    rm -rf $kernel.tmp $ramdisk.tmp dummy1 dummy2 > /dev/null 2>&1
}

# check for image unpack
check_image_unpack $CM_IMAGE      cm-kernel      cm-ramdisk
check_image_unpack $ANDROID_IMAGE android-kernel android-ramdisk
check_image_unpack $FFOS_IMAGE    ffos-kernel    ffos-ramdisk

# check for image repack (we use original image as valid one)
check_image_repack $CM_IMAGE      cm-kernel      cm-ramdisk      $CM_IMAGE
check_image_repack $ANDROID_IMAGE android-kernel android-ramdisk $ANDROID_IMAGE
check_image_repack $FFOS_IMAGE    ffos-kernel    ffos-ramdisk    $FFOS_IMAGE

# create a dummy image and testing unpack/repack
dummy_image_check $CM_IMAGE       d1-kernel      d1-ramdisk
dummy_image_check $ANDROID_IMAGE  d2-kernel      d2-ramdisk
dummy_image_check $FFOS_IMAGE     d3-kernel      d3-ramdisk

echo ""
echo "UNITTEST PASS"