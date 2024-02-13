#!/bin/bash
#=================================================
# File name: patch_kernel.sh
# System Required: Linux
# Version: 1.0
# Lisence: GPL-3.0
# Author: AsVow
# Blog: https://asvow.com
#=================================================
set -e

patch_path="$(dirname "$0")/kernel"

if [ "$DEVICE" == "nanopi-r4s" ]; then
    for dir in $OPENWRTROOT/target/linux/rockchip/patches*/; do
        cp -r $patch_path/rockchip/*.patch $dir
    done
fi
