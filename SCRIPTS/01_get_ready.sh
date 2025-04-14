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
openwrt_repo="https://github.com/openwrt/openwrt.git"
immortalwrt_repo="https://github.com/immortalwrt/immortalwrt.git"
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

# 开始克隆仓库，并行执行
clone_repo $openwrt_repo v24.10.0 openwrt &
clone_repo $immortalwrt_repo v24.10.0 immortalwrt &
clone_repo $openwrt_patch kernel-6.6 OpenWrt-Patch
clone_repo $openwrt_add_repo v24.10 openwrt-package
clone_repo $openwrt_add_repo helloworld helloworld
clone_repo $dockerman_repo main luci-app-dockerman
clone_repo $golang_repo 24.x golang
clone_repo $nginx_repo openwrt-24.10 nginx
clone_repo $node_repo packages-24.10 node
clone_repo $default_settings openwrt-24.10 default_settings
clone_repo $docker_repo main docker
clone_repo $dockerd_repo master dockerd
clone_repo $containerd_repo main containerd
clone_repo $runc_repo main runc

# 等待所有后台任务完成
wait
