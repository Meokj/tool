#!/bin/bash

set -e

if [[ "$EUID" -ne 0 ]]; then
  echo "请使用 root 用户运行此脚本！"
  exit 1
fi

if [ -f /etc/os-release ]; then
  . /etc/os-release
  if [[ "$ID" != "debian" && "$ID" != "ubuntu" ]]; then
    echo "此脚本仅支持 Debian/Ubuntu 系统，当前系统：$ID"
    exit 1
  fi
else
  echo "无法检测系统类型！"
  exit 1
fi

echo "=== 更新软件包索引 ==="
apt update

echo "=== 安装 nftables ==="
apt install -y nftables

echo "=== 启用并启动 nftables 服务 ==="
systemctl enable nftables
systemctl start nftables

read -p "请输入 SSH 登录端口进行放行：" SSH_PORT

echo "=== 生成 nftables 配置文件 ==="
cat > /etc/nftables.conf <<EOF
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0;
        policy drop;

        ct state established,related accept
        iif lo accept

        # 放行 ICMP（仅IPv4 ）
        ip protocol icmp accept

        # 放行常用端口
        tcp dport { $SSH_PORT, 80, 443, 53 } accept
        udp dport 53 accept

    }

    chain forward {
        type filter hook forward priority 0;
        policy drop;
    }

    chain output {
        type filter hook output priority 0;
        policy accept;
    }
}
EOF

echo "=== 加载新的规则 ==="
systemctl reload nftables

echo "=== 当前生效的规则集："
nft list ruleset

echo "=== nftables 已安装并配置完成！==="
