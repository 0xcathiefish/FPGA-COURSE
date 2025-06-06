#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
树莓派UART串口通信脚本
用于发送自定义字节数据
"""

import serial
import time
import sys

# ========== 自定义数据变量 ==========
# 在这里定义你要发送的自定义字节数据
CUSTOM_DATA = [0xff]  # 示例：字节数组
# CUSTOM_DATA = "Hello FPGA"                   # 也可以是字符串
# CUSTOM_DATA = 0x55                           # 也可以是单个字节
# CUSTOM_DATA = "DEADBEEF"                     # 也可以是十六进制字符串
# ======================================

class UARTSender:
    def __init__(self, port='/dev/ttyS0', baudrate=9600, timeout=1):
        """
        初始化UART连接
        
        参数:
        port: 串口设备路径 (树莓派默认: /dev/ttyS0)
        baudrate: 波特率 (默认: 9600)
        timeout: 超时时间 (默认: 1秒)
        """
        self.port = port
        self.baudrate = baudrate
        self.timeout = timeout
        self.ser = None
        
    def connect(self):
        """建立串口连接"""
        try:
            self.ser = serial.Serial(
                port=self.port,
                baudrate=self.baudrate,
                bytesize=serial.EIGHTBITS,
                parity=serial.PARITY_NONE,
                stopbits=serial.STOPBITS_ONE,
                timeout=self.timeout
            )
            print(f"成功连接到串口: {self.port}")
            print(f"波特率: {self.baudrate}")
            return True
        except serial.SerialException as e:
            print(f"串口连接失败: {e}")
            return False
    
    def send_bytes(self, data):
        """
        发送字节数据
        
        参数:
        data: 要发送的数据 (可以是bytes、bytearray或字符串)
        """
        if not self.ser or not self.ser.is_open:
            print("串口未连接")
            return False
            
        try:
            if isinstance(data, str):
                # 如果是字符串，转换为UTF-8字节
                data = data.encode('utf-8')
            elif isinstance(data, int):
                # 如果是单个整数，转换为bytes
                data = bytes([data])
            elif isinstance(data, list):
                # 如果是整数列表，转换为bytes
                data = bytes(data)
                
            bytes_sent = self.ser.write(data)
            self.ser.flush()  # 确保数据发送完毕
            print(f"成功发送 {bytes_sent} 字节: {data.hex()}")
            return True
            
        except Exception as e:
            print(f"发送数据失败: {e}")
            return False
    
    def send_hex_string(self, hex_string):
        """
        发送十六进制字符串
        
        参数:
        hex_string: 十六进制字符串，如 "48656C6C6F" 或 "48 65 6C 6C 6F"
        """
        try:
            # 移除空格和其他分隔符
            hex_string = hex_string.replace(' ', '').replace('-', '').replace(':', '')
            
            # 确保是偶数长度
            if len(hex_string) % 2 != 0:
                hex_string = '0' + hex_string
                
            # 转换为bytes
            data = bytes.fromhex(hex_string)
            return self.send_bytes(data)
            
        except ValueError as e:
            print(f"无效的十六进制字符串: {e}")
            return False
    
    def read_bytes(self, num_bytes=1):
        """读取指定数量的字节"""
        if not self.ser or not self.ser.is_open:
            print("串口未连接")
            return None
            
        try:
            data = self.ser.read(num_bytes)
            if data:
                print(f"接收到 {len(data)} 字节: {data.hex()}")
                return data
            else:
                print("没有接收到数据")
                return None
        except Exception as e:
            print(f"读取数据失败: {e}")
            return None
    
    def close(self):
        """关闭串口连接"""
        if self.ser and self.ser.is_open:
            self.ser.close()
            print("串口已关闭")

def send_custom_data():
    """发送自定义数据"""
    uart = UARTSender()
    
    if uart.connect():
        print(f"发送自定义数据: {CUSTOM_DATA}")
        uart.send_bytes(CUSTOM_DATA)
        uart.close()
    else:
        print("连接失败")

if __name__ == "__main__":
    send_custom_data()
