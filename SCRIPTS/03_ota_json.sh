#!/bin/sh

### OTA json
mkdir -p ota
OTA_URL="https://github.com/oppen321/ZeroWrt-Action/releases/download"
# x86_64
SHA256=$(sha256sum bin/targets/x86/64*/*-generic-squashfs-combined-efi.img.gz | awk '{print $1}')
cat > ota/fw.json <<EOF
{
  "x86_64": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256",
      "url": "$OTA_URL/24.10.1/zerowrt-vip-v24.10.1-r25.04.17-k6.6.86-x86-64-generic-squashfs-combined-efi.img.gz"
    }
  ]
}
EOF
# rockchip
SHA256=$(sha256sum bin/targets/rockchip/armv8*/*-squashfs-sysupgrade.img.gz | awk '{print $1}')
{
  "friendlyarm,nanopi-r4s": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256",
      "url": "$OTA_URL/24.10.1/zerowrt-vip-v24.10.1-r25.04.15-k6.6.86-rockchip-armv8-friendlyarm_nanopi-r4s-squashfs-sysupgrade.img.gz"
    }
  ]
}
EOF




