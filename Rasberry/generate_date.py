#!/usr/bin/env python3

def generate_spi_data():
    """
    读取ins.txt文件并生成SPI发送数据格式
    格式: 0xc5 + 位模式 + 数据值 (8个一组)
    """
    
    # 位模式循环
    bit_patterns = [0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80]
    
    try:
        # 读取ins.txt文件
        with open('./src/ins.txt', 'r') as f:
            data_lines = f.readlines()
        
        # 解析十六进制数据
        data_values = []
        for line in data_lines:
            line = line.strip()
            if line.startswith('0x'):
                try:
                    value = int(line, 16)
                    data_values.append(value)
                except ValueError:
                    continue
        
        print(f"读取到 {len(data_values)} 个数据值")
        
        # 生成Rust数组格式
        rust_code = []
        rust_code.append("        // 第一帧 - 保持原格式不变")
        rust_code.append("        0xc5, 0x01, 0x00,  // 第1行")
        rust_code.append("        0xc5, 0x02, 0x08,  // 第2行") 
        rust_code.append("        0xc5, 0x04, 0x18,  // 第3行")
        rust_code.append("        0xc5, 0x08, 0x1c,  // 第4行")
        rust_code.append("        0xc5, 0x10, 0x10,  // 第5行")
        rust_code.append("        0xc5, 0x20, 0x1c,  // 第6行")
        rust_code.append("        0xc5, 0x40, 0x28,  // 第7行")
        rust_code.append("        0xc5, 0x80, 0x48,  // 第8行")
        rust_code.append("")
        rust_code.append("        // 后续数据 - 使用ins.txt内容按8字节组格式")
        
        # 按8个一组处理数据
        group_count = 1
        for i in range(0, len(data_values), 8):
            group = data_values[i:i+8]
            
            # 如果不足8个，用0x00补充
            while len(group) < 8:
                group.append(0x00)
            
            # 生成一行数据
            line_parts = []
            for j, data_val in enumerate(group):
                bit_pattern = bit_patterns[j]
                line_parts.append(f"0xc5, 0x{bit_pattern:02X}, 0x{data_val:02X}")
            
            rust_code.append(f"        {', '.join(line_parts)},")
            group_count += 1
        
        # 输出到文件
        with open('generated_spi_data.txt', 'w') as f:
            f.write('\n'.join(rust_code))
        
        print(f"生成了 {group_count} 组数据")
        print("数据已保存到 generated_spi_data.txt")
        print("你可以复制其中的内容替换main.rs中的bytes_to_send数组")
        
    except FileNotFoundError:
        print("错误: 找不到ins.txt文件")
    except Exception as e:
        print(f"错误: {e}")

if __name__ == "__main__":
    generate_spi_data() 
