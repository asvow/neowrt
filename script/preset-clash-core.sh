#!/bin/bash
#=================================================
# File name: preset-clash-core.sh
# System Required: Linux
# Version: 1.0
# Lisence: MIT
# Author: SuLingGG
# Blog: https://mlapp.cn
#=================================================

mkdir -p files/etc/openclash/core
CLASH_DEV_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/dev/clash-linux-${1}.tar.gz"
CLASH_TUN_URL=$(curl -fsSL https://api.github.com/repos/vernesong/OpenClash/contents/master/premium\?ref\=core | grep download_url | grep $1 | awk -F '"' '{print $4}' | grep -v "v3" )
CLASH_META_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-${1}.tar.gz"
GEOIP_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
GEOSITE_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"
pushd files/etc/openclash
wget -qO- $CLASH_DEV_URL | tar xOvz > core/clash
wget -qO- $CLASH_TUN_URL | gunzip -c > core/clash_tun
wget -qO- $CLASH_META_URL | tar xOvz > core/clash_meta
wget -qO- $GEOIP_URL > GeoIP.dat
wget -qO- $GEOSITE_URL > GeoSite.dat
chmod +x core/clash*
popd
