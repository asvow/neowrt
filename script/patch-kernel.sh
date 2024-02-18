#!/bin/bash
#=================================================
# File name: patch-kernel.sh
# System Required: Linux
# Version: 1.0
# Lisence: GPL-3.0
# Author: AsVow
# Blog: https://asvow.com
#=================================================
patch_path="$GITHUB_WORKSPACE/patch/kernel"

if [ "$DEVICE" == "nanopi-r4s" ]; then
    for dir in $OPENWRTROOT/target/linux/rockchip/patches*/; do
        cp -r $patch_path/rockchip/*.patch $dir
    done
fi