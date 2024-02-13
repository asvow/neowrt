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
rm -rf luci-app-adguardhome luci-app-argon-config luci-app-cpufreq luci-app-diskman luci-app-dockerman luci-app-mosdns luci-app-openclash luci-app-tailscale luci-app-zerotier || true       
popd
pushd feeds/luci/themes
rm -rf luci-theme-argon || true       
popd


# Enter the "package" directory.
cd package


# Add neo-addon
# Include autocore & luci-app-adguardhome & luci-app-dockerman & luci-app-tailscale & luci-app-zerotier
git clone --recurse https://github.com/asvow/neo-addon

# Add luci-app-alist
if [ ! -d "../feeds/luci/applications/luci-app-alist" ]; then
  git clone https://github.com/sbwml/luci-app-alist alist
fi

# Add luci-app-cpufreq
clone_and_extract https://github.com/immortalwrt/luci applications/luci-app-cpufreq
clone_and_extract https://github.com/immortalwrt/immortalwrt package/emortal/cpufreq

# Add luci-app-diskman
mkdir parted
wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/Parted.Makefile -O parted/Makefile
clone_and_extract https://github.com/lisaac/luci-app-diskman applications/luci-app-diskman

# Add luci-app-irqbalance
if [ ! -d "../feeds/luci/applications/luci-app-irqbalance" ]; then
  clone_and_extract https://github.com/openwrt/luci applications/luci-app-irqbalance
fi

# Add luci-app-mosdns
# drop mosdns and v2ray-geodata packages that come with the source
find ../ | grep Makefile | grep v2ray-geodata | xargs rm -f
find ../ | grep Makefile | grep mosdns | xargs rm -f
git clone https://github.com/sbwml/luci-app-mosdns -b v5 mosdns
git clone https://github.com/sbwml/v2ray-geodata

# Add luci-app-openclash
clone_and_extract https://github.com/vernesong/OpenClash luci-app-openclash

# Add luci-proto-external
if [ ! -d "../feeds/luci/protocols/luci-proto-external" ]; then
  clone_and_extract https://github.com/openwrt/luci protocols/luci-proto-external
fi

# Add external-protocol
if [ ! -d "../feeds/packages/net/external-protocol" ]; then
  clone_and_extract https://github.com/openwrt/packages net/external-protocol
fi

# Add luci-theme-argon
clone_and_extract https://github.com/immortalwrt/luci themes/luci-theme-argon
clone_and_extract https://github.com/immortalwrt/luci applications/luci-app-argon-config


# Return to "openwrt" directory.
cd ../

# Execute all preset shell files in the script directory.
find ../script/ -name "preset-*.sh" -exec {} \;

# Execute all shell files in the patch directory.
find ../patch/ -name "*.sh" -exec {} \;
