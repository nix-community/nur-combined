#!/usr/bin/env python3
import argparse
import asyncio
import copy
import hashlib
import json
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

import aiohttp

# --- 配置区 ---

# 修改为你的 GitHub 用户名或组织名 (作为默认值)
REPO_OWNER = "lxl66566"

# 定义需要检查的目标系统架构和 libc 库 (仅在初始化新包时使用)
# 格式: (架构-系统, libc)
TARGET_PLATFORMS = [
    ("x86_64-linux", "gnu"),
    ("x86_64-linux", "musl"),
    ("aarch64-linux", "gnu"),
    ("aarch64-linux", "musl"),
]

# 当更新所有包时，线程池的最大并发数
MAX_CONCURRENT_UPDATES = 4

PKGS_DIR = Path(__file__).parent / "pkgs"

# --- 核心功能 ---


async def get_latest_github_release(session, owner, package_name):
    """从 GitHub API 获取最新的 release tag。"""
    url = f"https://api.github.com/repos/{owner}/{package_name}/releases/latest"
    try:
        async with session.get(url) as response:
            if response.status == 200:
                data = await response.json()
                return data.get("tag_name")
            else:
                print(
                    f"    [!] 无法获取 {owner}/{package_name} 的最新 release (状态: {response.status})。"
                )
                return None
    except aiohttp.ClientError as e:
        print(f"    [!] 获取 {owner}/{package_name} release 时网络错误: {e}")
        return None


async def calculate_sha256_from_url(session, url):
    """从 URL 下载文件并计算其 SHA256 哈希值，处理 404 错误。"""
    try:
        async with session.get(url) as response:
            if response.status == 200:
                hasher = hashlib.sha256()
                while True:
                    chunk = await response.content.read(8192)
                    if not chunk:
                        break
                    hasher.update(chunk)
                return hasher.hexdigest()
            elif response.status == 404:
                # print(f"    [*] 资源未找到 (404): {url}") # 可选：取消注释以显示详细跳过信息
                return None
            else:
                print(f"    [!] 下载失败 (状态: {response.status}): {url}")
                return None
    except aiohttp.ClientError as e:
        print(f"    [!] 下载时网络错误: {url}, 错误: {e}")
        return None


async def process_single_package(package_name, binary_name=None):
    """
    处理单个包的核心逻辑：获取最新版本，并更新或创建 source-info.json。
    """
    print(f"[*] 开始处理包: {package_name}")
    source_info_path = PKGS_DIR / package_name / "source-info.json"

    # 步骤 1: 提前解析 source-info.json 以获取 owner 和现有结构
    current_info = {}
    repo_owner = REPO_OWNER  # 默认 owner

    if source_info_path.exists():
        try:
            with open(source_info_path, "r") as f:
                current_info = json.load(f)
            repo_owner = current_info.get("owner", REPO_OWNER)
        except (json.JSONDecodeError, KeyError):
            print(f"    [!] {source_info_path} 文件损坏，将使用默认 owner 并重新生成。")

    if repo_owner != REPO_OWNER:
        print(f"    [*] 检测到自定义 owner: {repo_owner}")

    async with aiohttp.ClientSession() as session:
        latest_version = await get_latest_github_release(
            session, repo_owner, package_name
        )

        if not latest_version:
            print(f"[!] 无法为 {repo_owner}/{package_name} 找到最新的 release，跳过。")
            return

        if current_info.get("version") == latest_version:
            print(f"    [-] {package_name} 已经是最新版本 ({latest_version})。")
            return
        elif "version" in current_info:
            print(
                f"    [+] {package_name} 有新版本: {current_info.get('version')} -> {latest_version}"
            )
        else:
            print(
                f"    [+] {package_name} 的 source-info.json 不存在或无版本信息，将创建。版本: {latest_version}"
            )

        # 步骤 2: 决定要处理的平台
        tasks_with_keys = []
        platforms_to_process = []

        # 如果存在 hashes 结构，则根据它来处理
        if current_info.get("hashes"):
            print("    [*] 发现现有 hashes 结构，将根据 source-info.json 进行处理。")
            for arch_os, platform_data in current_info["hashes"].items():
                for platform_key, details in platform_data.items():
                    platforms_to_process.append((arch_os, platform_key, details))
        # 否则，回退到默认的 TARGET_PLATFORMS (用于 init)
        else:
            print(
                "    [*] 未发现 hashes 结构，将使用默认 TARGET_PLATFORMS 进行初始化。"
            )
            for arch_os, libc in TARGET_PLATFORMS:
                target_system = f"{arch_os.replace('-linux', '')}-unknown-linux-{libc}"
                details = {"targetSystem": target_system}
                platforms_to_process.append((arch_os, libc, details))

        # 步骤 3: 并发获取所有平台的哈希值
        for arch_os, platform_key, details in platforms_to_process:
            template_url = details.get("template")
            target_system = details.get("targetSystem", "")

            if template_url:
                url = (
                    template_url.replace("__pname__", package_name)
                    .replace("__bname__", binary_name or package_name)
                    .replace("__owner__", repo_owner)
                    .replace("__version__", latest_version)
                    .replace("__targetSystem__", target_system)
                )
            else:
                # 如果没有模板，则使用默认 GitHub URL 结构
                url = f"https://github.com/{repo_owner}/{package_name}/releases/download/{latest_version}/{binary_name or package_name}-{target_system}.tar.gz"

            print(f"    [*] 添加下载任务: {url}")
            task = asyncio.create_task(calculate_sha256_from_url(session, url))
            # 保存任务和其对应的键及原始信息，以便后续重建
            tasks_with_keys.append((task, (arch_os, platform_key, details)))

        if not tasks_with_keys:
            print("[!] 没有找到任何需要处理的平台。")
            return

        # 执行所有下载和计算任务
        tasks = [t for t, k in tasks_with_keys]
        hashes_results = await asyncio.gather(*tasks)

        # 步骤 4: 构建新的 source-info 数据结构
        # 从现有信息开始，只更新 sha256
        new_hashes = copy.deepcopy(current_info.get("hashes", {}))

        found_any_hash = False
        for i, result_sha256 in enumerate(hashes_results):
            _task, (arch_os, platform_key, details) = tasks_with_keys[i]

            if result_sha256:
                found_any_hash = True
                # 确保嵌套字典存在
                if arch_os not in new_hashes:
                    new_hashes[arch_os] = {}
                if platform_key not in new_hashes[arch_os]:
                    new_hashes[arch_os][platform_key] = details  # 从 init 场景中填充

                # 更新 sha256
                new_hashes[arch_os][platform_key]["sha256"] = result_sha256

        if not found_any_hash:
            print(
                f"[!] 未能为 {package_name} 的 {latest_version} 版本获取到任何哈希值。"
            )
            return

        # 准备写入文件
        new_source_info = {
            "owner": repo_owner,
            "version": latest_version,
            "hashes": new_hashes,
        }

        source_info_path.parent.mkdir(exist_ok=True)
        with open(source_info_path, "w") as f:
            json.dump(new_source_info, f, indent=2)

        print(
            f"[✓] 成功更新/创建 {package_name} 的 source-info.json 至版本 {latest_version}"
        )


def run_process_single_package(package_name, binary_name=None):
    """同步的包装器，用于在线程池中运行异步函数"""
    try:
        asyncio.run(process_single_package(package_name, binary_name))
    except Exception as e:
        print(f"[!!!] 处理 {package_name} 时发生意外错误: {e}")


# --- 命令行接口处理 ---


def handle_init(args):
    """处理 'init' 命令"""
    print(f"--- 初始化 {len(args.packages)} 个包 ---")
    binary_name = args.binary_name
    for package in args.packages:
        pkg_dir = PKGS_DIR / package
        if not pkg_dir.is_dir():
            print(f"[!] 目录 '{package}' 不存在，正在创建...")
            pkg_dir.mkdir(parents=True, exist_ok=True)
        run_process_single_package(package, binary_name)


def handle_update(args):
    """处理 'update' 命令"""
    if args.packages:
        print(f"--- 更新 {len(args.packages)} 个指定的包 ---")
        for package in args.packages:
            pkg_dir = PKGS_DIR / package
            if not pkg_dir.is_dir():
                print(f"[!] 找不到包目录 '{package}'，跳过。")
                continue
            run_process_single_package(package)
    else:
        print("--- 扫描并更新所有包 ---")
        packages_to_update = [
            p.name
            for p in PKGS_DIR.iterdir()
            if p.is_dir() and (p / "source-info.json").exists()
        ]

        if not packages_to_update:
            print("未找到任何含有 source-info.json 的包目录。")
            return

        print(f"找到 {len(packages_to_update)} 个包: {', '.join(packages_to_update)}")
        print(f"使用最多 {MAX_CONCURRENT_UPDATES} 个并发任务进行更新...")

        with ThreadPoolExecutor(max_workers=MAX_CONCURRENT_UPDATES) as executor:
            executor.map(run_process_single_package, packages_to_update)


def main():
    parser = argparse.ArgumentParser(
        description="管理 Nix 项目的 source-info.json 文件。",
        formatter_class=argparse.RawTextHelpFormatter,
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    parser_init = subparsers.add_parser(
        "init", help="为一个或多个新包初始化 source-info.json。"
    )
    parser_init.add_argument("packages", nargs="+", help="需要初始化的包的目录名。")
    parser_init.add_argument(
        "-b",
        "--binary-name",
        help="（可选）指定下载链接中使用的二进制文件名，默认为包名。",
    )
    parser_init.set_defaults(func=handle_init)

    parser_update = subparsers.add_parser(
        "update",
        help=(
            "更新包的 source-info.json。\n"
            "  - 如果提供了包名，则只更新指定的包。\n"
            "  - 如果未提供包名，则更新当前目录下所有包含 source-info.json 的包。"
        ),
    )
    parser_update.add_argument(
        "packages", nargs="*", help="（可选）需要更新的包的目录名。"
    )
    parser_update.set_defaults(func=handle_update)

    args = parser.parse_args()
    args.func(args)
    print("\n--- 所有任务完成 ---")


if __name__ == "__main__":
    main()
