# vendor 源码备份清单

本目录备份 openstick feed 各包编译所需的上游源码快照（按 Makefile 钉选的提交归档），
用于上游仓库或 lkiuyu 个人仓库被删除后仍可复编。

> 现状：**三个 lkiuyu 包**（android-tools、gc、qcom-firmware）已通过 `USE_SOURCE_DIR` 指向本目录本地源码，
> 编译时不再联网下载；workflow 会把这三个目录复制进构建树 `ufi001c/vendor/`。
> 上游开源的 qrtr、rmtfs、libusbgx、ModemManager 仍按 Makefile 在线拉取，本目录仅作离线备份快照。

## 已入库快照

| 目录 | feed 包 | 上游 URL | 钉选提交 | 版本 | PKG_MIRROR_HASH |
|---|---|---|---|---|---|
| `android-tools` | utils/android-tools（adbd / adb） | https://github.com/lkiuyu/android-tools.git | `6cea387346c9a49e0d7acbbe74f1cec62fcaec67` | 4.2.2 | `a8bf52d7892231e3fa91b9c91a116dc0b455de7bebce699871d7f9d96edefd8b` |
| `gc` | utils/gc（USB gadget） | https://github.com/lkiuyu/gc.git | `1e2b4d9480cf75663212a2bb7c550f3aae07ef50` | 20260310 | `58f8ad3f91e8488acc6f034ba0da1efb13a39cfe94f397047a72be827c076bc3` |
| `qrtr` | utils/qrtr | https://github.com/linux-msm/qrtr.git | `5923eea97377f4a3ed9121b358fd919e3659db7b` | 1.1 | `783cbf7846675eeeea7f24758c996f0fd144fb1e166ce6686afd7f7d89aaa3c6` |
| `rmtfs` | utils/rmtfs | https://github.com/linux-msm/rmtfs.git | `586372e575f5cc1a7cbb170219ab6df98f394cae` | 1.1.1 | `6086bb554c1f604a7e15d9010e3ccfea01cda88cb1df2978944f2a150136848d` |
| `libusbgx` | libs/libusbgx | https://github.com/linux-usb-gadgets/libusbgx.git | `dbedf16f80c5b4e1807ea4f80cc89d1f15d36f0a` | 0.3.0 | `43ebc3de10dc5de12cc390e16330e2844166fb80b53c1f2a0b77b9a98970a368` |
| `qcom-firmware` | firmware/qcom-firmware | https://github.com/lkiuyu/qcom-firmware.git | `e64f8cfd2a3aabe58633609f33e23c5c9d00730e` | 1034.2.4 | `0635114ff4d989bbfb24e7359bf6ce726398414be259a19cd4605924ed176437` |
| `ModemManager` | net/modemmanager | https://gitlab.freedesktop.org/mobile-broadband/ModemManager.git | tag `1.24.0` | 1.24.0 | `b81e0fc5a112fa52dd7ec72cdb684e10b04755a3492ea392cf6cde5688bb0e03` |

> **ModemManager** 以 gitlab 归档包 `ModemManager-1.24.0.tar.gz`（2.1M，sha256 `50e166bb24acb00bcaed814483920dfbc5b26d5424faee974b54c702e425a7c7`）存放，
> 不是 Makefile 下载的 git tar.xz；离线接入时解压为本地源码目录，4 个补丁在 `feed-openstick/net/modemmanager/patches/`。

> **qcom-firmware 仅归档本机 UFI003 所需的两个文件**，其余 16 台设备的 modem/nv blob 未入库：
> - `openstick-ufi003-modem.bin`（64M，FAT 镜像，内含 mba/modem/WCNSS）sha256 `0f2e4425f13bbda6029b677208abcffcfb2e93e64f266d5a26c039009413f20f`
> - `openstick-ufi003-nv.bin`（30K，WiFi nv 校准数据）sha256 `f85a3aeadcc9a496493cfd505e11d0110d62ac5d7d7ef7a2a1950e375f2297e1`

## 未入库（编译时仍联网拉取）

| 包 / feed | 上游 URL | 钉选 | 未备份原因 |
|---|---|---|---|
| packages feed | https://github.com/immortalwrt/packages.git | feeds.conf.default | 官方 feed 整树（约 73M），未备份 |
| luci feed | https://github.com/immortalwrt/luci.git | feeds.conf.default | 官方 feed 整树（约 334M），未备份 |
| routing / telephony / video feeds | https://github.com/openwrt/{routing,telephony,video}.git | feeds.conf.default | 官方 feed，未备份 |
| smpackage feed | https://github.com/kenzok8/small-package | diy-part1.sh 追加 | 第三方 feed，未备份 |
| store feed | https://github.com/linkease/istore.git;main | diy-part1.sh 追加 | 第三方 feed，未备份 |
| dl/ 工具链与库 tarball | 各包 Makefile `PKG_SOURCE_URL` | — | 上游 release/源码包，数量多，未逐一归档 |

## 复编说明

- **已本地化（不依赖在线）**：android-tools、gc、qcom-firmware 的 Makefile 用 `USE_SOURCE_DIR:=$(TOPDIR)/ufi001c/vendor/<目录>` 把本地快照链入 `PKG_BUILD_DIR`，跳过下载；qcom-firmware 的解包已裁剪为只处理 ufi003。
- **仍在线拉取**：qrtr、rmtfs、libusbgx、ModemManager 上游开源，`make download` 照常取 tarball；若日后也要离线，可仿照上面用 `USE_SOURCE_DIR` 接入对应快照（ModemManager 需先解压 tar.gz）。
- 校验完整性用表中 `PKG_MIRROR_HASH`；核心构建树、openstick feed 配方、种子配置与补丁已随本仓库根目录固化，本表只覆盖 feed 引用的外部源码。
