#!/bin/bash

echo "=== SPI 状态检查 ==="

echo "1. 检查 SPI 设备文件："
ls -la /dev/spi* 2>/dev/null || echo "未找到 SPI 设备文件"

echo -e "\n2. 检查 SPI 驱动模块："
lsmod | grep spi || echo "未找到 SPI 驱动模块"

echo -e "\n3. 检查设备树状态："
if [ -d /proc/device-tree/soc/ ]; then
    find /proc/device-tree/soc/ -name "*spi*" -type d 2>/dev/null || echo "未找到 SPI 设备树节点"
fi

echo -e "\n4. 检查内核消息："
dmesg | grep -i spi | tail -5

echo -e "\n5. 检查 GPIO 状态："
if command -v gpio &> /dev/null; then
    gpio readall | grep -E "(MOSI|MISO|SCLK|CE)"
else
    echo "gpio 命令不可用，请安装 wiringpi"
fi
