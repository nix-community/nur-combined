#!/usr/bin/env python3
import subprocess
import json
import sys
from pathlib import Path
import re

EXCLUDED_INPUTS = {"lix", "lix-module"}


def main():
    flake_path = Path("flake.lock")
    if not flake_path.exists():
        print("❌ flake.lock not found.")
        sys.exit(1)

    with open(flake_path) as f:
        data = json.load(f)

    root_node = data.get("nodes", {}).get("root", {})
    all_inputs = root_node.get("inputs", {})
    to_update = [name for name in all_inputs if name not in EXCLUDED_INPUTS]

    if not to_update:
        print(f"⚠️ No inputs to update after excluding: {', '.join(EXCLUDED_INPUTS)}")
        sys.exit(0)

    print(
        f"🔄 Updating {len(to_update)} inputs (excluding: {', '.join(EXCLUDED_INPUTS)})"
    )

    # 运行 nix flake update 并捕获输出
    try:
        result = subprocess.run(
            ["nix", "flake", "update"] + to_update,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
        )
    except subprocess.CalledProcessError as e:
        print("❌ nix flake update failed:")
        print(e.output)
        sys.exit(e.returncode)

    output = result.stdout

    # 解析输出，提取每个更新输入的“旧版本 → 新版本”信息
    # nix flake update 通常输出格式类似：
    # • Updated input 'nur':
    #     'github:nix-community/NUR/77e5f5ba0fe9184f2056e6bf447e47e89cfc5940' (date)
    #   → 'github:nix-community/NUR/72feb9594806cfe8a68b171d9f47e818a5999b5c' (date)
    updates = []
    lines = output.splitlines()
    current_input = None
    old_rev = None
    new_rev = None

    for line in lines:
        line = line.strip()
        # 匹配更新输入标题
        m_input = re.match(r"• Updated input '(.+)':", line)
        if m_input:
            # 如果之前有收集到一个更新，保存它
            if current_input and old_rev and new_rev:
                updates.append((current_input, old_rev, new_rev))
            current_input = m_input.group(1)
            old_rev = None
            new_rev = None
            continue

        # 匹配旧版本行
        m_old = re.match(r"'([^']+)' \([^)]+\)$", line)
        if m_old and old_rev is None:
            old_rev = m_old.group(1)
            continue

        # 匹配箭头行，获取新版本
        m_new = re.match(r"→ '([^']+)' \([^)]+\)$", line)
        if m_new:
            new_rev = m_new.group(1)
            continue

    # 最后一个更新收录
    if current_input and old_rev and new_rev:
        updates.append((current_input, old_rev, new_rev))

    if not updates:
        print("⚠️ No detailed update info found.")
    else:
        print("\n✨ Update details:")
        for inp, old, new in updates:
            # 简化展示，只留最后7字符的commit哈希（常见习惯）
            old_hash = old.split("/")[-1][-7:]
            new_hash = new.split("/")[-1][-7:]
            print(f"- {inp}: {old_hash} → {new_hash}")

    # 你可以返回这个输出，用于GitHub Action里做PR body等
    # 这里直接打印到stdout，Action捕获即可


if __name__ == "__main__":
    main()
