#!/bin/bash
clear

### 基础部分 ###
# 使用 O2 级别的优化
sed -i 's/Os/O2/g' include/target.mk

# 更新 Feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 移除 SNAPSHOT 标签
sed -i 's,-SNAPSHOT,,g' include/version.mk
sed -i 's,-SNAPSHOT,,g' package/base-files/image-config.in
sed -i '/CONFIG_BUILDBOT/d' include/feeds.mk
sed -i 's/;)\s*\\/; \\/' include/feeds.mk

# nginx - latest version
rm -rf feeds/packages/net/nginx
cp -rf ../nginx ./feeds/packages/net/nginx
sed -i 's/procd_set_param stdout 1/procd_set_param stdout 0/g;s/procd_set_param stderr 1/procd_set_param stderr 0/g' feeds/packages/net/nginx/files/nginx.init

# nginx - ubus
sed -i 's/ubus_parallel_req 2/ubus_parallel_req 6/g' feeds/packages/net/nginx/files-luci-support/60_nginx-luci-support
sed -i '/ubus_parallel_req/a\        ubus_script_timeout 300;' feeds/packages/net/nginx/files-luci-support/60_nginx-luci-support

# nginx - config
curl -s https://raw.githubusercontent.com/oppen321/OpenWrt/refs/heads/main/ngnix/luci.locations > feeds/packages/net/nginx/files-luci-support/luci.locations
curl -s https://raw.githubusercontent.com/oppen321/OpenWrt/refs/heads/main/ngnix/uci.conf.template > feeds/packages/net/nginx-util/files/uci.conf.template

# uwsgi - fix timeout
sed -i '$a cgi-timeout = 600' feeds/packages/net/uwsgi/files-luci-support/luci-*.ini
sed -i '/limit-as/c\limit-as = 5000' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
# disable error log
sed -i "s/procd_set_param stderr 1/procd_set_param stderr 0/g" feeds/packages/net/uwsgi/files/uwsgi.init

# uwsgi - performance
sed -i 's/threads = 1/threads = 2/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
sed -i 's/processes = 3/processes = 4/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
sed -i 's/cheaper = 1/cheaper = 2/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini

# rpcd - fix timeout
sed -i 's/option timeout 30/option timeout 60/g' package/system/rpcd/files/rpcd.config
sed -i 's#20) \* 1000#60) \* 1000#g' feeds/luci/modules/luci-base/htdocs/luci-static/resources/rpc.js

# 切换bash
sed -i 's#ash#bash#g' package/base-files/files/etc/passwd
sed -i '\#export ENV=/etc/shinit#a export HISTCONTROL=ignoredups' package/base-files/files/etc/profile
mkdir -p files/root
curl -so files/root/.bash_profile https://git.kejizero.online/zhao/files/raw/branch/main/root/.bash_profile
curl -so files/root/.bashrc https://git.kejizero.online/zhao/files/raw/branch/main/root/.bashrc

# 更换为 ImmortalWrt Uboot 以及 Target
rm -rf target/linux/rockchip
cp -rf ../immortalwrt/target/linux/rockchip target/linux/rockchip
cp -rf ../OpenWrt-Patch/rockchip/* ./target/linux/rockchip/patches-6.6/
rm -rf package/boot/{rkbin,uboot-rockchip,arm-trusted-firmware-rockchip}
cp -rf ../immortalwrt/package/boot/uboot-rockchip package/boot/uboot-rockchip
cp -rf ../immortalwrt/package/boot/arm-trusted-firmware-rockchip package/boot/arm-trusted-firmware-rockchip
sed -i '/REQUIRE_IMAGE_METADATA/d' target/linux/rockchip/armv8/base-files/lib/upgrade/platform.sh

# Disable Mitigations
sed -i 's,rootwait,rootwait mitigations=off,g' target/linux/rockchip/image/default.bootscript
sed -i 's,@CMDLINE@ noinitrd,noinitrd mitigations=off,g' target/linux/x86/image/grub-efi.cfg
sed -i 's,@CMDLINE@ noinitrd,noinitrd mitigations=off,g' target/linux/x86/image/grub-iso.cfg
sed -i 's,@CMDLINE@ noinitrd,noinitrd mitigations=off,g' target/linux/x86/image/grub-pc.cfg

# TTYD
sed -i 's/services/system/g' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i '3 a\\t\t"order": 50,' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i 's/procd_set_param stdout 1/procd_set_param stdout 0/g' feeds/packages/utils/ttyd/files/ttyd.init
sed -i 's/procd_set_param stderr 1/procd_set_param stderr 0/g' feeds/packages/utils/ttyd/files/ttyd.init

# 修改默认ip
sed -i "s/192.168.1.1/10.0.0.1/g" package/base-files/files/bin/config_generate

# 修改名称
sed -i 's/OpenWrt/ZeroWrt/' package/base-files/files/bin/config_generate

# banner
cp -rf ../openwrt-package/banner  ./package/base-files/files/etc/banner

### FW4 ###
rm -rf ./package/network/config/firewall4
cp -rf ../openwrt_main/package/network/config/firewall4 ./package/network/config/firewall4

# make olddefconfig
wget -qO - https://raw.githubusercontent.com/oppen321/OpenWrt-Patch/refs/heads/kernel-6.6/kernel/0003-include-kernel-defaults.mk.patch | patch -p1

# LRNG
cp -rf ../OpenWrt-Patch/lrng/* ./target/linux/generic/hack-6.6/
echo '
# CONFIG_RANDOM_DEFAULT_IMPL is not set
CONFIG_LRNG=y
CONFIG_LRNG_DEV_IF=y
# CONFIG_LRNG_IRQ is not set
CONFIG_LRNG_JENT=y
CONFIG_LRNG_CPU=y
# CONFIG_LRNG_SCHED is not set
CONFIG_LRNG_SELFTEST=y
# CONFIG_LRNG_SELFTEST_PANIC is not set
' >>./target/linux/generic/config-6.6

# module
cp -rf ../OpenWrt-Patch/kernel/0001-linux-module-video.patch ./
git apply 0001-linux-module-video.patch

# bbr
cp -rf ../OpenWrt-Patch/bbr3/* ./target/linux/generic/backport-6.6/

# bcmfullcone
cp -rf ../OpenWrt-Patch/bcmfullcone/* ./target/linux/generic/hack-6.6/

# FW4
mkdir -p package/network/config/firewall4/patches
cp -f ../OpenWrt-Patch/firewall/firewall4_patches/*.patch package/network/config/firewall4/patches/
sed -i 's|$(PROJECT_GIT)/project|https://github.com/openwrt|g' package/network/config/firewall4/Makefile

# libnftnl
mkdir -p package/libs/libnftnl/patches
cp -f ../OpenWrt-Patch/firewall/libnftnl/*.patch package/libs/libnftnl/patches/

# nftables
mkdir -p package/network/utils/nftables/patches
cp -f ../OpenWrt-Patch/firewall/nftables/*.patch package/network/utils/nftables/patches/

# Shortcut-FE支持
cp -rf ../OpenWrt-Patch/sfe/* ./target/linux/generic/hack-6.6/

# NAT6
patch -p1 < ../OpenWrt-Patch/firewall/100-openwrt-firewall4-add-custom-nft-command-support.patch

# igc-fix
cp -rf ../OpenWrt-Patch/igc-fix/* ./target/linux/x86/patches-6.6/

# btf
cp -rf ../OpenWrt-Patch/btf/* ./target/linux/generic/hack-6.6/

# arm64 型号名称
cp -rf ../OpenWrt-Patch/arm/* ./target/linux/generic/hack-6.6/

# cgroupfs-mount
# fix unmount hierarchical mount
pushd feeds/packages
patch -p1 < ../../../OpenWrt-Patch/pkgs/cgroupfs-mount/0001-fix-cgroupfs-mount.patch
popd
# mount cgroup v2 hierarchy to /sys/fs/cgroup/cgroup2
mkdir -p feeds/packages/utils/cgroupfs-mount/patches
cp -rf ../OpenWrt-Patch/pkgs/cgroupfs-mount/900-mount-cgroup-v2-hierarchy-to-sys-fs-cgroup-cgroup2.patch ./feeds/packages/utils/cgroupfs-mount/patches/
cp -rf ../OpenWrt-Patch/pkgs/cgroupfs-mount/901-fix-cgroupfs-umount.patch ./feeds/packages/utils/cgroupfs-mount/patches/
cp -rf ../OpenWrt-Patch/pkgs/cgroupfs-mount/902-mount-sys-fs-cgroup-systemd-for-docker-systemd-suppo.patch ./feeds/packages/utils/cgroupfs-mount/patches/

# procps-ng - top
sed -i 's/enable-skill/enable-skill --disable-modern-top/g' feeds/packages/utils/procps-ng/Makefile

# (Shortcut-FE,bcm-fullcone,ipv6-nat,nft-rule,natflow,fullcone6)
pushd feeds/luci
patch -p1 < ../../../OpenWrt-Patch/firewall/luci/0001-luci-app-firewall-add-nft-fullcone-and-bcm-fullcone-.patch
patch -p1 < ../../../OpenWrt-Patch/firewall/luci/0002-luci-app-firewall-add-shortcut-fe-option.patch
patch -p1 < ../../../OpenWrt-Patch/firewall/luci/0003-luci-app-firewall-add-ipv6-nat-option.patch
patch -p1 < ../../../OpenWrt-Patch/firewall/luci/0004-luci-add-firewall-add-custom-nft-rule-support.patch
patch -p1 < ../../../OpenWrt-Patch/firewall/luci/0005-luci-app-firewall-add-natflow-offload-support.patch
patch -p1 < ../../../OpenWrt-Patch/firewall/luci/0006-luci-app-firewall-enable-hardware-offload-only-on-de.patch
patch -p1 < ../../../OpenWrt-Patch/firewall/luci/0007-luci-app-firewall-add-fullcone6-option-for-nftables-.patch
popd

pushd feeds/luci
patch -p1 < ../../../OpenWrt-Patch/luci/0001-luci-mod-system-add-modal-overlay-dialog-to-reboot.patch
patch -p1 < ../../../OpenWrt-Patch/luci/0002-luci-mod-status-displays-actual-process-memory-usage.patch
patch -p1 < ../../../OpenWrt-Patch/luci/0003-luci-mod-status-storage-index-applicable-only-to-val.patch
patch -p1 < ../../../OpenWrt-Patch/luci/0004-luci-mod-status-firewall-disable-legacy-firewall-rul.patch
patch -p1 < ../../../OpenWrt-Patch/luci/0005-luci-mod-system-add-refresh-interval-setting.patch
patch -p1 < ../../../OpenWrt-Patch/luci/0006-luci-mod-system-mounts-add-docker-directory-mount-po.patch
popd

### ADD PKG 部分 ###
cp -rf ../openwrt-package ./package
cp -rf ../helloworld ./package
rm -rf feeds/packages/utils/coremark
rm -rf feeds/luci/applications/luci-app-alist
rm -rf feeds/packages/net/{alist,adguardhome,zerotier,xray-core,v2ray-core,v2ray-geodata,sing-box,sms-tool}

# 更换 golang 版本
rm -rf feeds/packages/lang/golang
cp -rf ../golang ./feeds/packages/lang/golang

# node - prebuilt
rm -rf feeds/packages/lang/node
cp -rf ../node feeds/packages/lang/node

# fstools
rm -rf package/system/fstools
cp -rf ../fstools ./package/system/fstools

# util-linux
rm -rf package/utils/util-linux
cp -rf ../util-linux ./package/utils/util-linux

# nghttp3
rm -rf feeds/packages/libs/nghttp3
cp -rf ../nghttp3 ./feeds/packages/libs/nghttp3

# ngtcp2
rm -rf feeds/packages/libs/ngtcp2
cp -rf ../ngtcp2 ./package/libs/ngtcp2

# curl - fix passwall `time_pretransfer` check
rm -rf feeds/packages/net/curl
cp -rf ../curl ./feeds/packages/net/curl

# odhcpd RFC-9096
mkdir -p package/network/services/odhcpd/patches
cp -rf ../OpenWrt-Patch/pkgs/odhcpd/001-odhcpd-RFC-9096-compliance-openwrt-24.10.patch ./package/network/services/odhcpd/patches/001-odhcpd-RFC-9096-compliance.patch
pushd feeds/luci
patch -p1 < ../../../OpenWrt-Patch/pkgs/odhcpd/luci-mod-network-add-option-for-ipv6-max-plt-vlt.patch
popd

# urngd - 2020-01-21
rm -rf package/system/urngd
cp -rf ../urngd ./package/system/urngd

# zlib - 1.3
ZLIB_VERSION=1.3.1
ZLIB_HASH=38ef96b8dfe510d42707d9c781877914792541133e1870841463bfa73f883e32
sed -ri "s/(PKG_VERSION:=)[^\"]*/\1$ZLIB_VERSION/;s/(PKG_HASH:=)[^\"]*/\1$ZLIB_HASH/" package/libs/zlib/Makefile

# frpc
sed -i 's/procd_set_param stdout $stdout/procd_set_param stdout 0/g' feeds/packages/net/frp/files/frpc.init
sed -i 's/procd_set_param stderr $stderr/procd_set_param stderr 0/g' feeds/packages/net/frp/files/frpc.init
sed -i 's/stdout stderr //g' feeds/packages/net/frp/files/frpc.init
sed -i '/stdout:bool/d;/stderr:bool/d' feeds/packages/net/frp/files/frpc.init
sed -i '/stdout/d;/stderr/d' feeds/packages/net/frp/files/frpc.config
sed -i 's/env conf_inc/env conf_inc enable/g' feeds/packages/net/frp/files/frpc.init
sed -i "s/'conf_inc:list(string)'/& \\\\/" feeds/packages/net/frp/files/frpc.init
sed -i "/conf_inc:list/a\\\t\t\'enable:bool:0\'" feeds/packages/net/frp/files/frpc.init
sed -i '/procd_open_instance/i\\t\[ "$enable" -ne 1 \] \&\& return 1\n' feeds/packages/net/frp/files/frpc.init
patch -p1 < ../OpenWrt-Patch/pkgs/frpc/001-luci-app-frpc-hide-token.patch
patch -p1 < ../OpenWrt-Patch/pkgs/frpc/002-luci-app-frpc-add-enable-flag.patch

# samba4 - bump version
rm -rf feeds/packages/net/samba4
cp -rf ../samba4 feeds/packages/net/samba4
# liburing - 2.7 (samba-4.21.0)
rm -rf feeds/packages/libs/liburing
cp -rf ../liburing ./feeds/packages/libs/liburing
# enable multi-channel
sed -i '/workgroup/a \\n\t## enable multi-channel' feeds/packages/net/samba4/files/smb.conf.template
sed -i '/enable multi-channel/a \\tserver multi channel support = yes' feeds/packages/net/samba4/files/smb.conf.template
# default config
sed -i 's/#aio read size = 0/aio read size = 0/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/#aio write size = 0/aio write size = 0/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/invalid users = root/#invalid users = root/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/bind interfaces only = yes/bind interfaces only = no/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/#create mask/create mask/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/#directory mask/directory mask/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/0666/0644/g;s/0744/0755/g;s/0777/0755/g' feeds/luci/applications/luci-app-samba4/htdocs/luci-static/resources/view/samba4.js
sed -i 's/0666/0644/g;s/0777/0755/g' feeds/packages/net/samba4/files/samba.config
sed -i 's/0666/0644/g;s/0777/0755/g' feeds/packages/net/samba4/files/smb.conf.template

# rootfs files
cp -rf ../OpenWrt-Patch/files ./files

# Docker
rm -rf feeds/luci/applications/luci-app-dockerman
cp -rf ../luci-app-dockerman ./feeds/luci/applications/luci-app-dockerman
rm -rf feeds/packages/utils/{docker,dockerd,containerd,runc}
cp -rf ../docker feeds/packages/utils/docker
cp -rf ../dockerd feeds/packages/utils/dockerd
cp -rf ../containerd feeds/packages/utils/containerd
cp -rf ../runc feeds/packages/utils/runc
sed -i '/cgroupfs-mount/d' feeds/packages/utils/dockerd/Config.in
sed -i '/sysctl.d/d' feeds/packages/utils/dockerd/Makefile
pushd feeds/packages
patch -p1 < ../../../OpenWrt-Patch/docker/0001-dockerd-fix-bridge-network.patch
patch -p1 < ../../../OpenWrt-Patch/docker/0002-docker-add-buildkit-experimental-support.patch
patch -p1 < ../../../OpenWrt-Patch/docker/0003-dockerd-disable-ip6tables-for-bridge-network-by-defa.patch
popd

# UPnP
rm -rf feeds/{packages/net/miniupnpd,luci/applications/luci-app-upnp}
cp -rf ../miniupnpd ./feeds/packages/net/miniupnpd
cp -rf ../luci-app-upnp ./feeds/luci/applications/luci-app-upnp

# opkg
mkdir -p package/system/opkg/patches
cp -rf ../OpenWrt-Patch/opkg/0001-opkg-download-disable-hsts.patch ./package/system/opkg/patches/0001-opkg-download-disable-hsts.patch
cp -rf ../OpenWrt-Patch/opkg/0002-libopkg-opkg_install-copy-conffiles-to-the-system-co.patch ./package/system/opkg/patches/0002-libopkg-opkg_install-copy-conffiles-to-the-system-co.patch

# 加入作者信息
sed -i "s/DISTRIB_DESCRIPTION='*.*'/DISTRIB_DESCRIPTION='ZeroWrt-$(date +%Y%m%d)'/g"  package/base-files/files/etc/openwrt_release
sed -i "s/DISTRIB_REVISION='*.*'/DISTRIB_REVISION=' By OPPEN321'/g" package/base-files/files/etc/openwrt_release

# 主题设置
sed -i 's/bing/none/' package/openwrt-package/luci-app-argon-config/root/etc/config/argon
curl -L https://git.kejizero.online/zhao/files/raw/branch/main/images/bg1.jpg -o package/openwrt-package/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
sed -i 's#<a class="luci-link" href="https://github.com/openwrt/luci" target="_blank">Powered by <%= ver.luciname %> (<%= ver.luciversion %>)</a> /#<a class="luci-link" href="https://www.kejizero.online" target="_blank">探索无限</a> /#' package/openwrt-package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
sed -i 's|<a href="https://github.com/jerrykuku/luci-theme-argon" target="_blank">ArgonTheme <%# vPKG_VERSION %></a>|<a href="https://github.com/oppen321/ZeroWrt-Action" target="_blank">ZeroWrt-Action</a> |g' package/openwrt-package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
sed -i 's#<a class="luci-link" href="https://github.com/openwrt/luci" target="_blank">Powered by <%= ver.luciname %> (<%= ver.luciversion %>)</a> /#<a class="luci-link" href="https://www.kejizero.online" target="_blank">探索无限</a> /#' package/openwrt-package/luci-theme-argon/luasrc/view/themes/argon/footer_login.htm
sed -i 's|<a href="https://github.com/jerrykuku/luci-theme-argon" target="_blank">ArgonTheme <%# vPKG_VERSION %></a>|<a href="https://github.com/oppen321/ZeroWrt-Action" target="_blank">ZeroWrt-Action</a> |g' package/openwrt-package/luci-theme-argon/luasrc/view/themes/argon/footer_login.htm

# 版本设置
cat << 'EOF' >> feeds/luci/modules/luci-mod-status/ucode/template/admin_status/index.ut
<script>
function addLinks() {
    var section = document.querySelector(".cbi-section");
    if (section) {
        var links = document.createElement('div');
        links.innerHTML = '<div class="table"><div class="tr"><div class="td left" width="33%"><a href="https://qm.qq.com/q/JbBVnkjzKa" target="_blank">QQ交流群</a></div><div class="td left" width="33%"><a href="https://t.me/kejizero" target="_blank">TG交流群</a></div><div class="td left"><a href="https://openwrt.kejizero.online" target="_blank">固件地址</a></div></div></div>';
        section.appendChild(links);
    } else {
        setTimeout(addLinks, 100); // 继续等待 `.cbi-section` 加载
    }
}

document.addEventListener("DOMContentLoaded", addLinks);
</script>
EOF

# istoreos
sed -i 's/iStoreOS/ZeroWrt/' package/openwrt-package/istoreos-files/files/etc/board.d/10_system
sed -i 's/192.168.100.1/10.0.0.1/' package/openwrt-package/istoreos-files/Makefile

# update feeds
./scripts/feeds update -a
./scripts/feeds install -a
