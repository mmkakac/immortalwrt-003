# UFI003 · ImmortalWrt 云编译套件

针对 **MSM8916（高通410）随身WiFi，物理丝印 UFI003**（DTS `msm8916-thwc-ufi001c` 被 ufi003 profile 复用），aarch64_generic / musl。
核心构建树快照已冻结在本仓库，不再依赖 `lkiuyu/immortalwrt` 在线源码。

## 固定定制

- 目标 profile `openstick-ufi003`；仅产 **ext4** 镜像，关闭 squashfs
- 不含任何短信转发组件（smstools3 / sms-tool / DbusSmsForward / smsmanager 均排除）
- WiFi 驱动禁用 2GHz 40MHz，锁 HT20（补丁 `ufi001c/patches/010-wcn36xx-ht20-only.patch` + uci-defaults）
- 开机自启 USB gadget(gc) 与 adbd：`gc enabled=1 adb=1`（`files/etc/uci-defaults/zz-enable-gc-adb`）
- cloudflared 走 Remote-managed Token 模式，默认关闭、不固化凭证

## 目录

| 路径 | 内容 |
|---|---|
| `ufi001c/config.lean` | lean 种子配置（默认） |
| `ufi001c/config.full` | full 种子：以 lean 为基线叠加 DDNS / fullcone / IPv6 隧道 / 容器 / 磁盘工具 / 基带扩展 kmod |
| `ufi001c/diy-part1.sh` / `diy-part2.sh` | 投料脚本：接入本地 openstick feed、追加第三方 feed、排除短信转发 |
| `ufi001c/feed-openstick/` | 固化的 openstick feed 配方 / init / 补丁（原 `lkiuyu/openstick-feeds` @ aad1101），本地 src-link 接入 |
| `ufi001c/vendor/` | 外部源码快照与固件 blob；android-tools/gc/qcom-firmware 已 `USE_SOURCE_DIR` 切本地源码，详见 `vendor/MANIFEST.md`（上游地址、钉选提交、校验哈希） |
| `ufi001c/files/` | uci-defaults 开机默认配置 |
| `ufi001c/patches/` | wcn36xx HT20 内核补丁 |
| `ufi001c/packages/libffi/` | 补回的 base libffi 配方（glib2/modemmanager 依赖） |
| `.github/workflows/` | GitHub Actions 编译工作流，可选 lean / full |

## lean vs full

两者基线一致（ufi003 / 仅 ext4 / 4G 栈 / adbd / HT20 / 远程应用）。full 在 lean 之上额外加入：

- DDNS：`ddns-go`、`ddns-scripts`、`ddns-scripts-services`
- 全锥 NAT：`kmod-nft-fullcone`；IPv6 隧道 `6in4` 及防火墙扩展模块
- 基带 / NCM / 高通外设扩展 kmod（comgt-ncm、bam-dmux、rpmsg-wwan-ctrl、qcom-rproc 系列、wwan、USB ncm/serial/eth）
- 容器：`runc`、`tini`
- 磁盘工具：`fdisk`、`parted`、`dosfstools`、`exfat-fsck`
- 系统工具：`irqbalance`、`iw`、`coreutils`

> flow offloading / BBR 等第三方 turboacc 加速包在本仓 feed 无对应符号，未纳入。

## 备份范围与仍在外部的依赖

核心构建树、openstick feed 配方、种子配置、补丁、外部源码快照与 UFI003 固件 blob 已随本仓库固化；
三个 lkiuyu 个人仓库（android-tools、gc、qcom-firmware）已切本地源码，断这三个的上游也能编。
仍在编译时联网拉取的部分（qrtr/rmtfs/libusbgx/ModemManager 上游开源、官方/第三方 feed 整树、其余 dl 源码包）见 `ufi001c/vendor/MANIFEST.md`。

## 历史与还原

`main` 已压缩为单个快照提交；压缩前的完整 10 提交历史保留在 `backup/pre-squash` 分支。
若编译有问题需要还原：把 `main` 重置到 `backup/pre-squash` 即可恢复压缩前状态。
