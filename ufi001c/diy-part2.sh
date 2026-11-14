#!/bin/bash
set -u

# 1) 排除短信转发
for p in DbusSmsForwardCPlus DbusSmsForward smsmanager smstools3 sms-tool; do
  echo "# CONFIG_PACKAGE_${p} is not set" >> .config
done

# 1b) 封禁整组代理壳、子开关与代理内核
# 背景：passwall / passwall2 / ssr-plus 的 INCLUDE_* 子开关是顶层 bool/choice，
# 未被父程序门控，在 aarch64 上按架构默认 y；父程序虽未安装，其 select 仍会把
# xray-core / 3proxy 等内核拉进固件。这里显式写 not set 覆盖 feed 默认值。
# 未知符号 defconfig 阶段会自动忽略，不影响其他包。
PROXY_PKGS=(
  luci-app-passwall luci-app-passwall2 luci-app-ssr-plus luci-app-3cat
  luci-app-clash luci-app-clashoo luci-app-openclash luci-app-xray
  luci-app-microsocks luci-app-smartdns luci-app-smartdns_INCLUDE_WebUI
  v2raya luci-i18n-clashoo-zh-cn
  luci-app-passwall_INCLUDE_Haproxy luci-app-passwall_INCLUDE_Hysteria
  luci-app-passwall_INCLUDE_NaiveProxy
  luci-app-passwall_INCLUDE_Shadowsocks_Rust_Client
  luci-app-passwall_INCLUDE_Shadowsocks_Rust_Server
  luci-app-passwall_INCLUDE_Shadow_TLS luci-app-passwall_INCLUDE_Simple_Obfs
  luci-app-passwall_INCLUDE_SingBox luci-app-passwall_INCLUDE_SmartDNS
  luci-app-passwall_INCLUDE_V2ray_Geodata luci-app-passwall_INCLUDE_V2ray_Geoview
  luci-app-passwall_INCLUDE_V2ray_Plugin luci-app-passwall_INCLUDE_Xray
  luci-app-passwall_INCLUDE_Xray_Plugin
  luci-app-passwall2_Basic_Core_All luci-app-passwall2_Basic_Core_SingBox
  luci-app-passwall2_Basic_Core_Xray luci-app-passwall2_INCLUDE_Haproxy
  luci-app-passwall2_INCLUDE_ShadowsocksR_Libev_Client
  luci-app-passwall2_INCLUDE_ShadowsocksR_Libev_Server
  luci-app-passwall2_INCLUDE_Shadowsocks_Rust_Client
  luci-app-passwall2_INCLUDE_Shadowsocks_Rust_Server
  luci-app-passwall2_INCLUDE_Simple_Obfs luci-app-passwall2_INCLUDE_V2ray_Plugin
  luci-app-passwall2_Iptables_Transparent_Proxy
  luci-app-passwall2_Nftables_Transparent_Proxy
  luci-app-ssr-plus_INCLUDE_ChinaDNS_NG luci-app-ssr-plus_INCLUDE_GeoData
  luci-app-ssr-plus_INCLUDE_Http_Proxy luci-app-ssr-plus_INCLUDE_Kcptun
  luci-app-ssr-plus_INCLUDE_Mihomo luci-app-ssr-plus_INCLUDE_MosDNS
  luci-app-ssr-plus_INCLUDE_NaiveProxy
  luci-app-ssr-plus_INCLUDE_ShadowsocksR_Libev_Client
  luci-app-ssr-plus_INCLUDE_ShadowsocksR_Libev_Server
  luci-app-ssr-plus_INCLUDE_Shadowsocks_Rust_Client
  luci-app-ssr-plus_INCLUDE_Shadowsocks_Rust_Server
  luci-app-ssr-plus_INCLUDE_Shadowsocks_Simple_Obfs
  luci-app-ssr-plus_INCLUDE_Shadowsocks_V2ray_Plugin
  luci-app-ssr-plus_INCLUDE_Shadow_TLS luci-app-ssr-plus_INCLUDE_Xray
  luci-app-ssr-plus_Iptables_Transparent_Proxy
  luci-app-ssr-plus_Nftables_Transparent_Proxy
  bsbf-autoconf-cellular bsbf-autoconf-dhcp bsbf-bonding bsbf-client-web
  bsbf-mptcp bsbf-netspeed bsbf-quectel-usbnet bsbf-rate-limiting
  xray-core xray-plugin xray-example v2ray-core v2ray-plugin v2ray-geoip
  v2ray-geosite v2ray-geosite-ir sing-box sing-box-tiny trojan trojan-go
  trojan-plus hysteria brook naiveproxy microsocks chinadns-ng smartdns
  smartdns-ui dns2socks dns2socks-rust ipt2socks shadow-tls
  simple-obfs-client simple-obfs-server
  shadowsocks-libev-ss-local shadowsocks-libev-ss-redir shadowsocks-libev-ss-server
  shadowsocks-libev-ss-tunnel shadowsocksr-libev-ssr-check shadowsocksr-libev-ssr-local
  shadowsocksr-libev-ssr-nat shadowsocksr-libev-ssr-redir shadowsocksr-libev-ssr-server
  shadowsocks-rust-sslocal shadowsocks-rust-ssmanager shadowsocks-rust-ssserver
  shadowsocks-rust-ssservice shadowsocks-rust-ssurl gost gost_engine-util
  ssocks ssocksd tuic-client tuic-server mihomo clashoo 3proxy
  3proxy-lib-pam 3proxy-lib-pcre 3proxy-lib-ssl 3proxy-lib-strings
  3proxy-lib-traffic 3proxy-lib-transparent 3proxy-mod-ftppr 3proxy-mod-mycrypt
  3proxy-mod-pop3p 3proxy-mod-proxy 3proxy-mod-smtpp 3proxy-mod-socks
  3proxy-mod-tcppm 3proxy-mod-tlspr 3proxy-mod-udppm
)
for p in "${PROXY_PKGS[@]}"; do
  echo "# CONFIG_PACKAGE_${p} is not set" >> .config
done

# ssr-plus 的 V2ray / Shadowsocks 选择是 choice，必须钉到 None。
# 注意：不能把 None 选项本身封成 not set，否则 choice 只剩内核可选，
# kconfig 会被迫选中 Xray 等内核（上一轮 xray-core 残留即此原因）。
SSR_NONE_PKGS=(
  luci-app-ssr-plus_INCLUDE_NONE_V2RAY
  luci-app-ssr-plus_INCLUDE_Shadowsocks_NONE_Client
  luci-app-ssr-plus_INCLUDE_Shadowsocks_NONE_Server
)
for p in "${SSR_NONE_PKGS[@]}"; do
  echo "CONFIG_PACKAGE_${p}=y" >> .config
done

# 1c) clashoo 孤儿语言包：原配方 i18n 缺主程序依赖，且 DEFAULT 跟随简中自动安装，
#     主程序没装也会被拉进固件。删掉该 DEFAULT，使语言包只在主程序安装时才带入。
CLASHOO_MK=feeds/smpackage/luci-app-clashoo/Makefile
if [ -f "$CLASHOO_MK" ]; then
  sed -i '/DEFAULT:=LUCI_LANG_zh_Hans/d' "$CLASHOO_MK"
fi

# 2) openstick-tweaks 笔误修正
grep -q '^CONFIG_PACKAGE_openstick-tweaks=y$' .config || echo 'CONFIG_PACKAGE_openstick-tweaks=y' >> .config

# 3) 安装40MHz补丁
#    关键：wcn36xx.ko 由 mac80211 backports 包编译，补丁必须打进
#    package/kernel/mac80211/patches/ath/ 才会作用于实际固件；
#    另拷一份到 target/linux/msm89xx/patches-* 作为内核树备份。
PATCH_SRC_DIR="${HT20_PATCH_DIR:-patches-ht20}"
if [ -d "$PATCH_SRC_DIR" ]; then
  mkdir -p package/kernel/mac80211/patches/ath
  cp "$PATCH_SRC_DIR"/*.patch package/kernel/mac80211/patches/ath/ 2>/dev/null || true
  for d in target/linux/msm89xx/patches-*; do
    [ -d "$d" ] && cp "$PATCH_SRC_DIR"/*.patch "$d/" 2>/dev/null || true
  done
  echo "补丁已安装到 backports patches/ath 与内核 patches-*"
fi

# 4) uci-defaults
[ -f files/etc/uci-defaults/99-ht20-default ] && chmod +x files/etc/uci-defaults/99-ht20-default
