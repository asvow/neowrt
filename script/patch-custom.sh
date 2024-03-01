#!/bin/bash
#=================================================
# File name: patch-custom.sh
# System Required: Linux
# Version: 1.0
# Lisence: GPL-3.0
# Author: AsVow
# Blog: https://asvow.com
#=================================================

# Correct path issues
Makefile_path="$({ find $OPENWRTROOT/package -name "Makefile" -not -name "Makefile.*"; } 2> "/dev/null")"

for file in ${Makefile_path}; do
  sed -i 's|../../lang/golang/golang-package.mk|$(TOPDIR)/feeds/packages/lang/golang/golang-package.mk|g' $file
  sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|g' $file
done

# Use dnsmasq-full instead of dnsmasq
sed -i 's/dnsmasq /dnsmasq-full /' $OPENWRTROOT/include/target.mk

# Replace the default startup script and configuration of tailscale.
sed -i '/\/etc\/init\.d\/tailscale/d;/\/etc\/config\/tailscale/d;' $OPENWRTROOT/feeds/packages/net/tailscale/Makefile

# Netavark: bomp version to 1.10.2 for native support nftables.
# sed -i "/PKG_VERSION:=/c\PKG_VERSION:=1.10.2" $OPENWRTROOT/feeds/packages/net/netavark/Makefile
# sed -i "/PKG_HASH:=/c\PKG_HASH:=5df03e3dc82e208dd49684e7b182ffe6c158ad9d9d06cba0c3d4820f471bfaa4" $OPENWRTROOT/feeds/packages/net/netavark/Makefile

# Fix docker bridge network
sed -i 's/list blocked_interfaces '\''wan'\''/#&/' $OPENWRTROOT/feeds/packages/utils/dockerd/files/etc/config/dockerd

# luci-app-dockerman: hide config buttons in overview page
if [ "$BRANCH" == "v23.05.2" ]; then
  patch_url="https://github.com/openwrt/luci/commit/568b44edb3bf545e424e7c1a3f162e753b190113.patch"

  pushd $OPENWRTROOT/feeds/luci
    wget $patch_url
    git apply $(basename $patch_url)
    rm $(basename $patch_url)
  popd
fi

# fix unmount hierarchical mount
mv $GITHUB_WORKSPACE/patch/cgroupfs/cgroupfs-mount.init $OPENWRTROOT/feeds/packages/utils/cgroupfs-mount/files/cgroupfs-mount.init

# cgroupfs v2
mkdir -p $OPENWRTROOT/feeds/packages/utils/cgroupfs-mount/patches
cp $GITHUB_WORKSPACE/patch/cgroupfs/900-add-cgroupfs2.patch $OPENWRTROOT/feeds/packages/utils/cgroupfs-mount/patches/900-add-cgroupfs2.patch

# firewall4: fix flow offload
pushd $OPENWRTROOT/package/network/config/firewall4
  mkdir -p patches
  cp $GITHUB_WORKSPACE/patch/firewall4/001-fix-fw4-flow-offload.patch patches
popd

# tailscale: bomp version to 1.60.1.
sed -i "/PKG_VERSION:=/c\PKG_VERSION:=1.60.1" $OPENWRTROOT/feeds/packages/net/tailscale/Makefile
sed -i "/PKG_HASH:=/c\PKG_HASH:=9766336845cef4d8b906145bc863f20ec8b9af71051471de45d7f964539a9817" $OPENWRTROOT/feeds/packages/net/tailscale/Makefile

# golang: bomp version to latest. 
rm -rf $OPENWRTROOT/feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 22.x $OPENWRTROOT/feeds/packages/lang/golang
