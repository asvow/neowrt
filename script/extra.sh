# Function to clone a repository and extract a specific directory
clone_and_extract() {
  repo_url=$1
  target_path=$2
  target_dir=../$(basename $target_path)
  git clone --depth 1 --filter=blob:none --sparse $repo_url temp
  pushd temp
  git sparse-checkout init --cone
  git sparse-checkout set $target_path
  mkdir -p $target_dir && mv -v $target_path/* $target_dir
  popd
  rm -rf temp
}

# Remove duplicate packages
pushd feeds/luci/applications
rm -rf luci-app-adguardhome luci-app-diskman luci-app-dockerman luci-app-mosdns luci-app-openclash luci-app-tailscale luci-app-zerotier || true       
popd


# Enter the "package" directory.
cd package


# Add neo-addon
# Include luci-app-adguardhome & luci-app-dockerman & luci-app-tailscale & luci-app-zerotier
git clone --recurse https://github.com/asvow/neo-addon

# Add luci-app-diskman
mkdir luci-app-diskman parted
wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/applications/luci-app-diskman/Makefile -O luci-app-diskman/Makefile
wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/Parted.Makefile -O parted/Makefile

# Add luci-app-irqbalance
if [ ! -d "../feeds/luci/applications/luci-app-irqbalance" ]; then
  clone_and_extract https://github.com/immortalwrt/luci applications/luci-app-irqbalance
  sed -i 's|include ../../luci.mk|include $(TOPDIR)/feeds/luci/luci.mk|' luci-app-irqbalance/Makefile
fi

# Add luci-app-openclash
clone_and_extract https://github.com/vernesong/OpenClash luci-app-openclash

# Add luci-proto-external
if [ ! -d "../feeds/luci/protocols/luci-proto-external" ]; then
  clone_and_extract https://github.com/immortalwrt/luci protocols/luci-proto-external
  sed -i 's|include ../../luci.mk|include $(TOPDIR)/feeds/luci/luci.mk|' luci-proto-external/Makefile
fi

# Add external-protocol
if [ ! -d "../feeds/packages/net/external-protocol" ]; then
  clone_and_extract https://github.com/immortalwrt/packages net/external-protocol
fi


# Return to "openwrt" directory.
cd ../


# Add luci-app-mosdns
# drop mosdns and v2ray-geodata packages that come with the source
find ./ | grep Makefile | grep v2ray-geodata | xargs rm -f
find ./ | grep Makefile | grep mosdns | xargs rm -f
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# Change default shell to zsh
sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd

# Use dnsmasq-full instead of dnsmasq
sed -i 's/dnsmasq /dnsmasq-full /' include/target.mk

# Replace the default startup script and configuration of tailscale.
sed -i '/\/etc\/init\.d\/tailscale/d;/\/etc\/config\/tailscale/d;' feeds/packages/net/tailscale/Makefile

# Netavark: bomp version to 1.10.2 for native support nftables.
sed -i "/PKG_VERSION:=/c\PKG_VERSION:=1.10.2" feeds/packages/net/netavark/Makefile
sed -i "/PKG_HASH:=/c\PKG_HASH:=5df03e3dc82e208dd49684e7b182ffe6c158ad9d9d06cba0c3d4820f471bfaa4" feeds/packages/net/netavark/Makefile

# Supplement for Chinese Localization
target_file="feeds/luci/modules/luci-base/po/zh_Hans/base.po"
echo >> $target_file
echo 'msgid "Externally managed interface"' >> $target_file
echo 'msgstr "外部协议"' >> $target_file
echo >> $target_file
echo 'msgid "Delay"' >> $target_file
echo 'msgstr "延迟"' >> $target_file
echo >> $target_file
echo 'msgid "Afer making changes to network using external protocol, network must be manually restarted."' >> $target_file
echo 'msgstr "使用外部协议更改网络后，需要重启网络服务。"' >> $target_file
echo >> $target_file
echo 'msgid "Search domain"' >> $target_file
echo 'msgstr "查找域"' >> $target_file
