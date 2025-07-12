#!/bin/bash
echo "卸载 iptables"
echo
read -rp "确定要继续吗？(y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    exit 0
fi

if ! grep -Ei 'debian|ubuntu' /etc/os-release > /dev/null; then
  echo "此脚本只适用于 Debian / Ubuntu 系统！"
  exit 1
fi

echo "停止 netfilter-persistent 服务（如果存在）..."
sudo systemctl stop netfilter-persistent || true
sudo systemctl disable netfilter-persistent || true

echo "卸载 iptables 和 iptables-persistent..."
sudo apt remove --purge -y iptables iptables-persistent

echo "清理无用依赖..."
sudo apt autoremove -y

echo "删除规则文件..."
sudo rm -f /etc/iptables/rules.v4 /etc/iptables/rules.v6

echo "卸载完成！当前已安装的 iptables 相关工具："
dpkg -l | grep iptables || echo "已全部卸载。"
