# vendor 源码备份清单

本目录备份 openstick feed 各包编译所需的上游源码快照（按 Makefile 钉选的提交归档），
用于上游仓库或 lkiuyu 个人仓库被删除后仍可复编。

> 现状：feed 的 `Makefile` 默认仍从上游 URL 下载源码 tarball；本目录是**离线备份快照**，
> 尚未把编译路径切到本地源码。上游在线时编译不读本目录；上游缺失时再按末尾「复编说明」切换。

## 已入库快照

| 目录 | feed 包 | 上游 URL | 钉选提交 | 版本 | PKG_MIRROR_HASH |
|---|---|---|---|---|---|
| `android-tools` | utils/android-tools（adbd / adb） | https://github.com/lkiuyu/android-tools.git | `6cea387346c9a49e0d7acbbe74f1cec62fcaec67` | 4.2.2 | `a8bf52d7892231e3fa91b9c91a116dc0b455de7bebce699871d7f9d96edefd8b` |
| `gc` | utils/gc（USB gadget） | https://github.com/lkiuyu/gc.git | `1e2b4d9480cf75663212a2bb7c550f3aae07ef50` | 20260310 | `58f8ad3f91e8488acc6f034ba0da1efb13a39cfe94f397047a72be827c076bc3` |
| `qrtr` | utils/qrtr | https://github.com/linux-msm/qrtr.git | `5923eea97377f4a3ed9121b358fd919e3659db7b` | 1.1 | `783cbf7846675eeeea7f24758c996f0fd144fb1e166ce6686afd7f7d89aaa3c6` |
| `rmtfs` | utils/rmtfs | https://github.com/linux-msm/rmtfs.git | `586372e575f5cc1a7cbb170219ab6df98f394cae` | 1.1.1 | `6086bb554c1f604a7e15d9010e3ccfea01cda88cb1df2978944f2a150136848d` |
| `libusbgx` | libs/libusbgx | https://github.com/linux-usb-gadgets/libusbgx.git | `dbedf16f80c5b4e1807ea4f80cc89d1f15d36f0a` | 0.3.0 | `43ebc3de10dc5de12cc390e16330e2844166fb80b53c1f2a0b77b9a98970a368` |

## 未入库（编译时仍联网拉取）

| 包 / feed | 上游 URL | 钉选 | 未备份原因 |
|---|---|---|---|
| qcom-firmware | https://github.com/lkiuyu/qcom-firmware.git | `e64f8cfd2a3aabe58633609f33e23c5c9d00730e` / 1034.2.4 | 全设备 modem.bin 固件 blob 合计约 1G；本机 UFI003 仅需 `openstick-ufi003-modem.bin`(64M) + `openstick-ufi003-nv.bin`(30K)，是否入库待确认 |
| modemmanager | https://gitlab.freedesktop.org/mobile-broadband/ModemManager.git | 1.24.0 | freedesktop 上游大仓，删除风险低；gitlab 克隆在本环境被断开，未归档 |
| packages feed | https://github.com/immortalwrt/packages.git | feeds.conf.default | 官方 feed 整树（约 73M），未备份 |
| luci feed | https://github.com/immortalwrt/luci.git | feeds.conf.default | 官方 feed 整树（约 334M），未备份 |
| routing / telephony / video feeds | https://github.com/openwrt/{routing,telephony,video}.git | feeds.conf.default | 官方 feed，未备份 |
| smpackage feed | https://github.com/kenzok8/small-package | diy-part1.sh 追加 | 第三方 feed，未备份 |
| store feed | https://github.com/linkease/istore.git;main | diy-part1.sh 追加 | 第三方 feed，未备份 |
| dl/ 工具链与库 tarball | 各包 Makefile `PKG_SOURCE_URL` | — | 上游 release/源码包，数量多，未逐一归档 |

## 复编说明

- 上游在线：`Makefile` 照常 `make download` 拉取 tarball，本目录快照不参与编译。
- 上游被删：把对应快照放到 `build_dir/<包>-<版本>`，或将 `PKG_SOURCE_URL` 改指本地路径，
  用表中 `PKG_MIRROR_HASH` 校验完整性；qrtr/rmtfs/libusbgx/android-tools/gc 均为源码树，可直接作为本地源码目录接入。
- 核心构建树、openstick feed 配方、种子配置与补丁已随本仓库根目录固化；本表只覆盖 feed 引用的外部源码。
