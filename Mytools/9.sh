#!/bin/bash
echo "安装iptables"
echo

if ! grep -Ei 'debian|ubuntu' /etc/os-release > /dev/null 2>&1; then
  echo "本脚本只支持 Debian 和 Ubuntu 系统！"
  exit 1
fi

if ! command -v iptables >/dev/null 2>&1; then
  echo "未检测到 iptables，正在安装..."
  sudo apt update
  sudo apt install -y iptables iptables-persistent
fi

if ! command -v ip6tables >/dev/null 2>&1; then
  echo "未检测到 ip6tables，正在安装..."
  sudo apt update
  sudo apt install -y iptables iptables-persistent
fi

echo
echo "当前 IPv4 iptables 规则："
sudo iptables -L INPUT -v -n --line-numbers
echo
echo "当前 IPv6 ip6tables 规则："
sudo ip6tables -L INPUT -v -n --line-numbers
echo

read -rp "请输入操作类型（add 表示添加规则，del 表示删除规则）： " ACTION
if [[ "$ACTION" != "add" && "$ACTION" != "del" ]]; then
  echo "无效操作类型，只能是 add 或 del"
  exit 1
fi

read -rp "请输入端口或端口范围（多个端口用英文逗号分隔，如 22,80,10000-20000）： " PORTS_INPUT

process_ports() {
  local action_flag
  if [[ "$ACTION" == "add" ]]; then
    action_flag="-A"
  else
    action_flag="-D"
  fi

  local proto=$1    
  local ipcmd=$2   
  local ports=$3

  IFS=',' read -ra parts <<< "$ports"
  for part in "${parts[@]}"; do
    if [[ "$part" =~ ^[0-9]+-[0-9]+$ ]]; then
      IFS='-' read -r start end <<< "$part"
      echo "$ACTION $ipcmd $proto 端口范围 $start-$end"
      sudo $ipcmd $action_flag INPUT -p "$proto" --dport "$start":"$end" -j ACCEPT
    elif [[ "$part" =~ ^[0-9]+$ ]]; then
      echo "$ACTION $ipcmd $proto 端口 $part"
      sudo $ipcmd $action_flag INPUT -p "$proto" --dport "$part" -j ACCEPT
    else
      echo "忽略无效端口格式: $part"
    fi
  done
}

if [[ "$ACTION" == "add" ]]; then
  sudo iptables -C INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || \
    sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

  sudo ip6tables -C INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || \
    sudo ip6tables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

  sudo iptables -C INPUT -i lo -j ACCEPT 2>/dev/null || \
    sudo iptables -A INPUT -i lo -j ACCEPT

  sudo ip6tables -C INPUT -i lo -j ACCEPT 2>/dev/null || \
    sudo ip6tables -A INPUT -i lo -j ACCEPT
fi

process_ports tcp iptables "$PORTS_INPUT"
process_ports udp iptables "$PORTS_INPUT"
process_ports tcp ip6tables "$PORTS_INPUT"
process_ports udp ip6tables "$PORTS_INPUT"

if [[ "$ACTION" == "add" ]]; then
  sudo iptables -P INPUT DROP
  sudo iptables -P FORWARD DROP
  sudo iptables -P OUTPUT ACCEPT

  sudo ip6tables -P INPUT DROP
  sudo ip6tables -P FORWARD DROP
  sudo ip6tables -P OUTPUT ACCEPT
fi

sudo netfilter-persistent save

echo
echo "操作完成！当前 IPv4 iptables 规则："
sudo iptables -L INPUT -v -n --line-numbers
echo
echo "当前 IPv6 ip6tables 规则："
sudo ip6tables -L INPUT -v -n --line-numbers
