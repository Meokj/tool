#!/bin/bash
clear
echo "卸载UFW"
echo
read -rp "确定要继续吗？(y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    exit 0
fi

echo "停止 ufw 服务..."
sudo systemctl stop ufw

echo "禁用 ufw 开机自启..."
sudo systemctl disable ufw

echo "卸载 ufw 防火墙..."
sudo apt-get remove --purge ufw -y

echo "ufw 已成功卸载！"
