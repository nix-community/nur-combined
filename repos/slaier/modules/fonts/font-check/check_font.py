#!/usr/bin/env python3
"""
字体字符支持检查工具
检查指定字体列表是否支持某个或某些字符
"""

import sys
from fontTools.ttLib import TTFont
import subprocess


def get_font_list():
    """获取系统字体列表"""
    try:
        result = subprocess.run(
            ['fc-list'],
            capture_output=True,
            text=True,
            check=True
        )
        fonts = set()
        for line in result.stdout.strip().split('\n'):
            if line:
                # fc-list 输出格式: /path/to/font: Family:Style
                # 使用 : 分割，取第一部分即字体路径
                font_path = line.split(':', 1)[0].strip()
                fonts.add(font_path)
        return sorted(fonts)
    except subprocess.CalledProcessError as e:
        print(f"Error executing fc-list: {e}", file=sys.stderr)
        return []


def check_char_in_font(font_path, char):
    """检查单个字体是否支持指定字符"""
    try:
        font = TTFont(font_path, lazy=True)
        # 获取字符的 Unicode 码点
        codepoint = ord(char)

        # 检查所有 cmap 表
        for table in font['cmap'].tables:
            if codepoint in table.cmap:
                font.close()
                return True
        font.close()
        return False
    except Exception as e:
        # 字体文件损坏或格式不支持等错误
        return False


def check_chars_in_font(font_path, chars):
    """检查单个字体是否支持所有指定字符"""
    try:
        font = TTFont(font_path, lazy=True)

        for char in chars:
            codepoint = ord(char)
            found = False
            for table in font['cmap'].tables:
                if codepoint in table.cmap:
                    found = True
                    break
            if not found:
                font.close()
                return False
        font.close()
        return True
    except Exception as e:
        return False


def main():
    if len(sys.argv) < 2:
        print("Usage: check_font.py <character> [font_path...]")
        print("       If no font_path is provided, all system fonts will be checked.")
        print("Example: check_font.py '字'")
        print("Example: check_font.py 'ABC' /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf")
        sys.exit(1)

    # 要检查的字符（可以是字符串）
    chars = sys.argv[1]

    # 获取字体列表
    font_paths = sys.argv[2:] if len(sys.argv) > 2 else get_font_list()

    if not font_paths:
        print("No fonts found.", file=sys.stderr)
        sys.exit(1)

    print(f"Checking {len(font_paths)} fonts for character(s): {repr(chars)}")
    print("-" * 80)

    # 检查每个字体
    supported_fonts = []
    for font_path in font_paths:
        if check_chars_in_font(font_path, chars):
            supported_fonts.append(font_path)
            print(f"✓ {font_path}")
        else:
            print(f"✗ {font_path}")

    print("-" * 80)
    print(f"Result: {len(supported_fonts)}/{len(font_paths)} fonts support the character(s).")

    # 输出简洁列表
    if supported_fonts:
        print("\nSupported fonts:")
        for font in supported_fonts:
            print(f"  {font}")


if __name__ == "__main__":
    main()
