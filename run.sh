#!/bin/bash
clear
while true; do
  echo
  read -rp "请输入要执行的脚本编号（0退出）： " num

  if [[ ! "$num" =~ ^[1-9][0-9]*$ ]]; then
    echo
    echo "输入错误，请输入大于0的纯数字且无空格"
    continue
  fi

  url="https://raw.githubusercontent.com/scattlights/Tools/main/Mytools/${num}.sh"
  
  if curl --silent --head --fail "$url" > /dev/null; then
    bash <(curl -s "$url")
  else
    echo
    echo "未找到编号为 $num 的脚本"
  fi
done
