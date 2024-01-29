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
rm -rf luci-app-adguardhome luci-app-diskman luci-app-dockerman luci-app-mosdns luci-app-openclash luci-app-zerotier || true       
popd
pushd feeds/luci/collections
rm -rf luci-lib-docker || true       
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

# Add luci-lib-docker
clone_and_extract https://github.com/lisaac/luci-lib-docker collections/luci-lib-docker

# Add luci-app-openclash
clone_and_extract https://github.com/vernesong/OpenClash luci-app-openclash


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
