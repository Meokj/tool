#!/bin/bash
clear
echo "卸载Nginx"
echo

if ! command -v nginx &> /dev/null; then
  echo "ℹ️ 未检测到已安装的 Nginx"
  exit 0
fi

read -rp "确定要继续吗？(y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    exit 0
fi

echo "⚠️  正在准备卸载 Nginx..."

if ! grep -Ei 'ubuntu|debian' /etc/os-release > /dev/null; then
  echo "❌ 当前系统不是 Ubuntu 或 Debian，退出脚本。"
  exit 1
fi

echo "🛑 停止 Nginx 服务..."
sudo systemctl stop nginx
sudo systemctl disable nginx

echo "📦 卸载 Nginx..."
sudo apt remove --purge -y nginx nginx-common nginx-core

echo "🧽 清理无用依赖..."
sudo apt autoremove -y
sudo apt autoclean

echo "🗑️ 删除默认网站目录 /var/www/html..."
sudo rm -rf /var/www/html

echo "🧹 删除配置和日志目录..."
sudo rm -rf /etc/nginx
sudo rm -rf /var/log/nginx

echo "✅ Nginx 卸载完成。"
