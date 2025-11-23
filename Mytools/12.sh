#!/bin/bash
echo
IPV6_ADDR=$(ip -6 addr show scope global | grep -oP '(?<=inet6 ).*(?= scope global)' | awk '{print $1}')

if [ -z "$IPV6_ADDR" ]; then
    echo "未检测到可用的全球 IPv6 地址，跳过 IPv6 优先配置"
    exit 0
else
    echo "检测到 IPv6 地址：$IPV6_ADDR"
    echo "准备启用 IPv6 DNS + IPv6 优先访问..."
fi

echo "正在备份 /etc/resolv.conf ..."
cp /etc/resolv.conf /etc/resolv.conf.bak.$(date +%s)

cat > /etc/resolv.conf <<EOF
nameserver 2606:4700:4700::1111
nameserver 2606:4700:4700::1001
nameserver 1.1.1.1
nameserver 8.8.8.8
EOF

echo "已更新 /etc/resolv.conf（IPv6 DNS 优先）"

echo "正在备份 /etc/gai.conf ..."

cp /etc/gai.conf /etc/gai.conf.bak.$(date +%s)

sed -i '/precedence ::ffff:0:0\/96/d' /etc/gai.conf

echo "precedence ::ffff:0:0/96  10" >> /etc/gai.conf

echo "已更新 /etc/gai.conf（IPv6 访问优先）"

echo "IPv6 可用，已应用 IPv6 DNS + IPv6 优先访问策略"

echo
