#!/bin/bash

# 这个脚本的作用是从不同的仓库中克隆openwrt相关的代码，并进行一些处理

# 定义一个函数，用来克隆指定的仓库和分支
clone_repo() {
  # 参数1是仓库地址，参数2是分支名，参数3是目标目录
  repo_url=$1
  branch_name=$2
  target_dir=$3
  # 克隆仓库到目标目录，并指定分支名和深度为1
  git clone -b $branch_name --depth 1 $repo_url $target_dir
}

# 定义一些变量，存储仓库地址和分支名
openwrt_release="$(curl -s https://github.com/openwrt/openwrt/tags | grep -Eo "v[0-9\.]+\-*r*c*[0-9]*.tar.gz" | sed -n '/[2-9][4-9]/p' | sed -n 1p | sed 's/.tar.gz//g')"
immortalwrt_release="$(curl -s https://github.com/immortalwrt/immortalwrt/tags | grep -Eo "v[0-9\.]+\-*r*c*[0-9]*.tar.gz" | sed -n '/[2-9][4-9]/p' | sed -n 1p | sed 's/.tar.gz//g')"
openwrt_repo="https://github.com/openwrt/openwrt.git"
immortalwrt_repo="https://github.com/immortalwrt/immortalwrt.git"
lean_repo="https://github.com/coolsnowwolf/lede"
openwrt_patch="https://github.com/oppen321/OpenWrt-Patch"
openwrt_add_repo="https://github.com/oppen321/openwrt-package"
dockerman_repo="https://github.com/oppen321/luci-app-dockerman"
golang_repo="https://github.com/sbwml/packages_lang_golang"
node_repo="https://github.com/sbwml/feeds_packages_lang_node-prebuilt"
nginx_repo="https://github.com/oppen321/feeds_packages_net_nginx"
default_settings="https://github.com/oppen321/default-settings"
miniupnpd_repo="https://git.kejizero.online/zhao/miniupnpd"
upnp_repo="https://git.kejizero.online/zhao/luci-app-upnp"
docker_repo="https://git.kejizero.online/zhao/packages_utils_docker"
dockerd_repo="https://git.kejizero.online/zhao/packages_utils_dockerd"
containerd_repo="https://git.kejizero.online/zhao/packages_utils_containerd"
runc_repo="https://git.kejizero.online/zhao/packages_utils_runc"
fstools_repo="https://github.com/sbwml/package_system_fstools"
util_linux_repo="https://github.com/sbwml/package_utils_util-linux"
nghttp3_repo="https://github.com/sbwml/package_libs_nghttp3"
ngtcp2_repo="https://github.com/sbwml/package_libs_ngtcp2"
curl_repo="https://github.com/sbwml/feeds_packages_net_curl"
urngd_repo="https://github.com/sbwml/package_system_urngd"
samba4_repo="https://github.com/sbwml/feeds_packages_net_samba4"
liburing_repo="https://github.com/sbwml/feeds_packages_libs_liburing"

# 开始克隆仓库，并行执行
clone_repo $openwrt_repo $openwrt_release openwrt &
clone_repo $immortalwrt_repo $immortalwrt_release immortalwrt &
clone_repo $openwrt_repo main openwrt_main
clone_repo $openwrt_repo openwrt-24.10 openwrt_24
clone_repo $lean_repo master lede
clone_repo $openwrt_patch kernel-6.6 OpenWrt-Patch
clone_repo $openwrt_add_repo v24.10 openwrt-package
clone_repo $openwrt_add_repo helloworld helloworld
clone_repo $dockerman_repo main luci-app-dockerman
clone_repo $golang_repo 24.x golang
clone_repo $nginx_repo openwrt-24.10 nginx
clone_repo $node_repo packages-24.10 node
clone_repo $default_settings openwrt-24.10 default_settings
clone_repo $miniupnpd_repo v2.3.7 miniupnpd
clone_repo $upnp_repo master luci-app-upnp
clone_repo $docker_repo main docker
clone_repo $dockerd_repo main dockerd
clone_repo $containerd_repo main containerd
clone_repo $runc_repo main runc
clone_repo $fstools_repo openwrt-24.10 fstools
clone_repo $util_linux_repo openwrt-24.10 util-linux
clone_repo $nghttp3_repo main nghttp3
clone_repo $ngtcp2_repo main ngtcp2
clone_repo $curl_repo main curl
clone_repo $urngd_repo main urngd
clone_repo $samba4_repo main samba4
clone_repo $liburing_repo main liburing

# 等待所有后台任务完成
wait

# 进行一些处理
find openwrt/package/* -maxdepth 0 ! -name 'firmware' ! -name 'kernel' ! -name 'base-files' ! -name 'Makefile' -exec rm -rf {} +
rm -rf ./openwrt_24/package/firmware ./openwrt_snap/package/kernel ./openwrt_snap/package/base-files ./openwrt_snap/package/Makefile
cp -rf ./openwrt_24/package/* ./openwrt/package/
cp -rf ./openwrt_24/feeds.conf.default ./openwrt/feeds.conf.default

# 退出脚本
exit 0
