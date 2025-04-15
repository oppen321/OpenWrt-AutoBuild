#!/bin/bash

# distfeeds.conf
mkdir -p files/etc/opkg
cat > files/etc/opkg/distfeeds.conf <<EOF
src/gz openwrt_base https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.1/packages/x86_64/base
src/gz openwrt_luci https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.1/packages/x86_64/luci
src/gz openwrt_packages https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.1/packages/x86_64/packages
src/gz openwrt_routing https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.1/packages/x86_64/routing
src/gz openwrt_telephony https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.1/packages/x86_64/telephony
src/gz openwrt_core https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.1/targets/x86/64/kmods/6.6.86-1-af351158cfb5febf5155a3aa53785982
EOF

mkdir -p files/usr/bin

AGH_CORE=$(curl -sL https://api.github.com/repos/AdguardTeam/AdGuardHome/releases/latest | grep /AdGuardHome_linux_amd64 | awk -F '"' '{print $4}')

wget -qO- $AGH_CORE | tar xOvz > files/usr/bin/AdGuardHome

chmod +x files/usr/bin/AdGuardHome

mkdir -p files/etc/openclash/core

CLASH_META_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-amd64.tar.gz"
GEOIP_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
GEOSITE_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"

wget -qO- $CLASH_META_URL | tar xOvz > files/etc/openclash/core/clash_meta
wget -qO- $GEOIP_URL > files/etc/openclash/GeoIP.dat
wget -qO- $GEOSITE_URL > files/etc/openclash/GeoSite.dat

chmod +x files/etc/openclash/core/clash*

# ZeroWrt选项菜单
mkdir -p files/bin
curl -L -o files/bin/ZeroWrt https://git.kejizero.online/zhao/files/raw/branch/main/bin/ZeroWrt
chmod +x files/bin/ZeroWrt
mkdir -p files/root
curl -L -o files/root/version.txt https://git.kejizero.online/zhao/files/raw/branch/main/bin/version.txt
chmod +x files/root/version.txt

# Adguardhome设置
mkdir -p files/etc
curl -L -o files/etc/AdGuardHome-dnslist.yaml https://git.kejizero.online/zhao/files/raw/branch/main/etc/AdGuardHome-dnslist.yaml
chmod +x files/etc/AdGuardHome-dnslist.yaml
curl -L -o files/etc/AdGuardHome-mosdns.yaml https://git.kejizero.online/zhao/files/raw/branch/main/etc/AdGuardHome-mosdns.yaml
chmod +x files/etc/AdGuardHome-mosdns.yaml
curl -L -o files/etc/AdGuardHome-dns.yaml https://git.kejizero.online/zhao/files/raw/branch/main/etc/AdGuardHome-dns.yaml
chmod +x files/etc/AdGuardHome-dns.yaml

# default_set
mkdir -p files/etc/config
curl -L -o files/etc/config/default_dhcp.conf https://raw.githubusercontent.com/oppen321/ZeroWrt/refs/heads/openwrt-24.10/files/default_dhcp.conf
curl -L -o files/etc/config/default_mosdns https://raw.githubusercontent.com/oppen321/ZeroWrt/refs/heads/openwrt-24.10/files/default_mosdns
curl -L -o files/etc/config/default_smartdns https://raw.githubusercontent.com/oppen321/ZeroWrt/refs/heads/openwrt-24.10/files/default_smartdns
curl -L -o files/etc/config/default_AdGuardHome https://raw.githubusercontent.com/oppen321/ZeroWrt/refs/heads/openwrt-24.10/files/default_AdGuardHome
curl -L -o files/etc/config/default_passwall https://raw.githubusercontent.com/oppen321/ZeroWrt/refs/heads/openwrt-24.10/files/default_passwall
curl -L -o files/etc/config/default_openclash https://raw.githubusercontent.com/oppen321/ZeroWrt/refs/heads/openwrt-24.10/files/default_openclash
chmod +x files/etc/config/default_dhcp.conf
chmod +x files/etc/config/default_mosdns
chmod +x files/etc/config/default_smartdns
chmod +x files/etc/config/default_AdGuardHome
chmod +x files/etc/config/default_passwall
chmod +x files/etc/config/default_openclash

