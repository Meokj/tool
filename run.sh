#!/bin/bash
while true; do
  echo "=================="
  echo "1. 修改SSH端口"
  echo "2. 系统更新和清理"
  echo "3. 安装UFW防火墙并启用"
  echo "4. UFW防火墙端口管理"
  echo "5. 清理日志和缓存"
  echo "6. 查看或修改当前时区"
  echo "7. 安装Nginx"
  echo "8. 卸载Nginx"
  echo "9. 卸载UFW防火墙"
  echo "=================="
  read -rp "请输入要执行的脚本编号（0退出）： " num

  if [[ ! "$num" =~ ^[0-9]+$ ]]; then
    echo
    echo "输入错误，请输入大于等于0的纯数字且无空格"
    continue
  fi

  if [[ "$num" == "0" ]]; then
    echo "退出脚本"
    exit 0
  fi

  url="https://raw.githubusercontent.com/scattlights/Tools/main/Mytools/${num}.sh"
  
  if curl --silent --head --fail "$url" > /dev/null; then
    bash <(curl -s "$url")
  else
    echo
    echo "未找到编号为 $num 的脚本"
  fi
done
