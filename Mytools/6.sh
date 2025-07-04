#!/bin/bash
clear
echo "查看或修改当前时区"
echo
read -rp "确定要继续吗？(y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    exit 0
fi

common_timezones=(
  "Asia/Shanghai"
  "Asia/Tokyo"
  "Asia/Singapore"
  "America/New_York"
  "America/Los_Angeles"
  "Europe/London"
  "Europe/Berlin"
  "UTC"
)

current_timezone=$(timedatectl | grep "Time zone" | awk '{print $3}')
echo "当前时区: $current_timezone"
echo

read -p "是否需要修改时区？(y/n): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "操作已取消，未修改时区。"
    exit 0
fi

echo "请选择一个新的时区："
for i in "${!common_timezones[@]}"; do
    printf "%2d) %s\n" "$i" "${common_timezones[$i]}"
done

echo
read -p "请输入序号 (0 ~ $((${#common_timezones[@]} - 1))): " index

if ! [[ "$index" =~ ^[0-9]+$ ]]; then
    echo "❌ 错误：请输入有效数字。"
    exit 1
fi

if [ "$index" -lt 0 ] || [ "$index" -ge "${#common_timezones[@]}" ]; then
    echo "❌ 错误：序号超出范围。"
    exit 1
fi

selected_timezone="${common_timezones[$index]}"
echo "✅ 你选择的时区是: $selected_timezone"
echo "🔧 正在设置时区..."

sudo timedatectl set-timezone "$selected_timezone"

echo "🎉 设置完成，当前时区为：$(timedatectl | grep 'Time zone')"
