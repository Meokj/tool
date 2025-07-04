#!/bin/bash
clear
echo "UFW 防火墙端口管理器"
echo

if ! command -v ufw &> /dev/null; then
    echo "未检测到 ufw，请先安装"
    exit 1
fi

read -rp "确定要继续吗？(y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    exit 0
fi

echo "当前已开放的端口："
sudo ufw status numbered
echo

while true; do
    read -rp "请选择操作类型（1: 添加端口，2: 删除端口，0: 退出）： " choice
    case "$choice" in
        1)
            while true; do
                read -rp "请输入要开放的端口（英文逗号分隔，例如 22,80,443），回车返回菜单： " ports
                if [[ -z "$ports" ]]; then
                    break
                fi

                if [[ $ports =~ ^[0-9]+(,[0-9]+)*$ ]]; then
                    for port in $(echo "$ports" | tr ',' ' '); do
                        sudo ufw allow "$port"
                    done
                    sudo ufw status numbered
                    break
                else
                    echo "输入格式错误，请使用英文逗号分隔端口"
                fi
            done
            ;;
        2)
            while true; do
                read -rp "请输入要删除的端口（英文逗号分隔，例如 22,80,443），回车返回菜单： " ports
                if [[ -z "$ports" ]]; then
                    break
                fi

                if [[ $ports =~ ^[0-9]+(,[0-9]+)*$ ]]; then
                    for port in $(echo "$ports" | tr ',' ' '); do
                        sudo ufw delete allow "$port"
                    done
                    sudo ufw status numbered
                    break
                else
                    echo "输入格式错误，请使用英文逗号分隔端口"
                fi
            done
            ;;
        0)
            echo "已退出。"
            exit 0
            ;;
        *)
            echo "无效选择，请输入 1、2 或 0。"
            ;;
    esac
done
