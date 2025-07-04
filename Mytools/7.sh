#!/bin/bash

if ! grep -Ei 'ubuntu|debian' /etc/os-release > /dev/null; then
  echo "❌ 当前系统不是 Ubuntu 或 Debian，已退出。"
  exit 1
fi

echo "🌐 正在为 Ubuntu/Debian 安装 Nginx..."

echo "📦 更新软件包索引..."
sudo apt update -y

echo "📥 安装 Nginx..."
sudo apt install -y nginx

echo "🚀 启动 Nginx 服务..."
sudo systemctl start nginx
sudo systemctl enable nginx

echo "🔍 检查 Nginx 运行状态..."
if systemctl is-active --quiet nginx; then
  echo "✅ Nginx 安装成功并已启动！"
else
  echo "❌ Nginx 安装失败或未成功启动，请检查日志。"
fi
