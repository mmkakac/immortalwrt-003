#!/bin/bash
set -u

# openstick feed 已固化到本仓库 ufi001c/feed-openstick，用本地 src-link 接入，
# 不再从 lkiuyu/openstick-feeds 在线克隆（配方/init/补丁随仓库备份；源码 tarball 仍在 download 阶段拉取）。
if [ -d "$PWD/ufi001c/feed-openstick" ]; then
	sed -i '/^src-git[a-z-]*[[:space:]]openstick/d' feeds.conf.default
	echo "src-link openstick $PWD/ufi001c/feed-openstick" >> feeds.conf.default
fi

# 第三方 feed：filebrowser 等应用来自这里，无条件追加
echo 'src-git smpackage https://github.com/kenzok8/small-package' >> feeds.conf.default
echo 'src-git store https://github.com/linkease/istore.git;main' >> feeds.conf.default

cat feeds.conf.default
