#!/bin/bash

echo "清理日志和缓存"

read -rp "确定要继续吗？(y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    exit 0
fi

LOG_DIRS=(
  "/var/log"
  "/tmp"
  "$HOME/.cache"
)

echo "清理日志目录..."
for dir in "${LOG_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    echo "处理目录: $dir"
    find "$dir" -type f \( -name "*.log" -o -name "*.gz" -o -name "*.old" \) -exec rm -f {} \;
    find "$dir" -type f -size +100M -exec rm -f {} \; # 删除大于100M的缓存文件
  fi
done

if command -v apt-get >/dev/null 2>&1; then
  echo "清理 APT 缓存..."
  sudo apt-get clean
  sudo apt-get autoremove -y
fi

if command -v yum >/dev/null 2>&1; then
  echo "清理 YUM 缓存..."
  sudo yum clean all
fi

if command -v journalctl >/dev/null 2>&1; then
  echo "清理 journald 日志..."
  sudo journalctl --vacuum-time=7d  # 删除7天前的日志
fi

echo "清理完成 ✅"
