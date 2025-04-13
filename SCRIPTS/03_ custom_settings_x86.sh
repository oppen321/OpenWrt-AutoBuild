#!/bin/bash

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
