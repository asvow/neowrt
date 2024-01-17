#!/bin/sh

# Set default system preferences
uci batch <<EOF
set system.@system[0].hostname='NeoWrt'
set system.@system[0].zonename='Asia/Shanghai'
set system.@system[0].timezone='CST-8'
delete system.ntp.server
add_list system.ntp.server="ntp.tencent.com"
add_list system.ntp.server="ntp1.aliyun.com"
add_list system.ntp.server="ntp.ntsc.ac.cn"
add_list system.ntp.server="cn.ntp.org.cn"
commit system
EOF

# Set default luci preferences
# uci batch <<EOF
# set luci.main.lang='auto'
# set luci.main.mediaurlbase='/luci-static/argon'
# commit luci
# EOF

# Set default network preferences
uci batch <<EOF
set network.lan.ipaddr='10.0.0.1'
delete network.globals.ula_prefix
commit network
EOF
/etc/init.d/network restart

# Set default dhcp preferences
# uci batch <<-EOF
# delete dhcp.lan.dhcpv6
# delete dhcp.lan.ra_flags
# add_list dhcp.lan.ra_flags="other-config"
# set dhcp.lan.max_preferred_lifetime="2700"
# set dhcp.lan.max_valid_lifetime="5400"
# commit dhcp
# EOF

# Disable opkg signature check
# sed -i 's/option check_signature/# option check_signature/g' /etc/opkg.conf

# Switch opkg to a Chinese mirror
#sed -i 's/downloads.openwrt.org/mirrors.tuna.tsinghua.edu.cn\/openwrt/g' /etc/opkg/distfeeds.conf

# Try to execute init.sh (if exists)
[ -f "/boot/init.sh" ] && /bin/sh /boot/init.sh

exit 0
