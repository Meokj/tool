#!/bin/bash
clear
echo "安装nftables"
echo

read -rp "确定要继续吗？(y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    exit 0
fi

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

if dpkg -l | grep -qw nftables; then
  echo "nftables 已经安装，无需重复安装，脚本退出。"
  exit 0
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

flush ruleset  # 清空当前所有 nftables 规则，确保从零开始配置

table inet filter {
    chain input {
        type filter hook input priority 0;
        policy drop;  # 默认拒绝所有进来的数据包，保证安全性
        
        # 允许已经建立和相关的连接通过，避免断开已有连接
        ct state established,related accept
        # 允许本地回环接口流量
        iif lo accept
        # 放行 ICMP
        ip protocol icmp accept
        ip6 nexthdr ipv6-icmp accept

        # 放行端口
        tcp dport { $SSH_PORT, 80, 443 } accept
    }

    chain forward {
        type filter hook forward priority 0;
        policy drop;  # 默认拒绝所有转发的数据包，阻止路由转发
    }

    chain output {
        type filter hook output priority 0;
        policy accept;  # 允许所有出站流量，不限制服务器向外的连接
    }
}
EOF

echo "=== 加载新的规则 ==="
systemctl reload nftables

echo "=== 当前生效的规则集："
nft list ruleset

echo "=== nftables 已安装并配置完成！==="
