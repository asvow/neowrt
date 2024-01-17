# Remove duplicate packages
pushd feeds/luci/applications
rm -rf luci-app-adguardhome luci-app-diskman luci-app-dockerman luci-app-mosdns luci-app-openclash || true       
popd
pushd feeds/luci/collections
rm -rf luci-lib-docker || true       
popd


# Enter the "package" directory.
cd package


# Add luci-app-adguardhome
git clone https://github.com/asvow/luci-app-adguardhome

# Add luci-app-diskman
mkdir luci-app-diskman parted
wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/applications/luci-app-diskman/Makefile -O luci-app-diskman/Makefile
wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/Parted.Makefile -O parted/Makefile

# Add luci-app-dockerman
git clone --depth 1 --filter=blob:none --sparse https://github.com/lisaac/luci-app-dockerman extra
pushd extra
git sparse-checkout init --cone
git sparse-checkout set applications/luci-app-dockerman
mv */* ../
popd
rm -rf extra

# Add luci-lib-docker
git clone --depth 1 --filter=blob:none --sparse https://github.com/lisaac/luci-lib-docker extra
pushd extra
git sparse-checkout init --cone
git sparse-checkout set collections/luci-lib-docker
mv */* ../
popd
rm -rf extra

# Add luci-app-openclash
git clone --depth 1 --filter=blob:none --sparse https://github.com/vernesong/OpenClash extra
pushd extra && rm -rf *
git sparse-checkout init --cone
git sparse-checkout set luci-app-openclash
mv * ../
popd
rm -rf extra


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
