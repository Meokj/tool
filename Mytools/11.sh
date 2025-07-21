#!/bin/bash
clear
echo "卸载nftables"
echo

read -rp "确定要继续吗？(y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    exit 0
fi

if dpkg -l | grep -qw nftables; then
  echo "检测到已安装 nftables，正在卸载..."
  systemctl stop nftables
  systemctl disable nftables
  apt remove -y nftables
  echo "nftables 已成功卸载！"
else
  echo "nftables 未安装，无需卸载。"
fi
