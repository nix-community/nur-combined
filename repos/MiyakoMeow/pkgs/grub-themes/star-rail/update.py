#!/usr/bin/env python3
"""
生成主题包信息的 JSON 文件并保存到 themes.json
"""

import json
import os
import sys
import argparse
import subprocess
import requests
import re
import logging
import hashlib

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    stream=sys.stderr,
)
logger = logging.getLogger()


def calculate_sha256_nix(url: str):
    """使用 nix-prefetch-url 获取文件的 SHA256 哈希"""
    try:
        result = subprocess.run(
            ["nix-prefetch-url", "--type", "sha256", url],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Error prefetching {url}: {e.stderr}", file=sys.stderr)
        raise
    except FileNotFoundError:
        print(
            "Error: nix-prefetch-url not found. Make sure Nix is installed.",
            file=sys.stderr,
        )
        raise


def extract_sha256_from_digest(digest: str):
    """从GitHub API的digest字段中提取SHA256哈希"""
    if digest and digest.startswith("sha256:"):
        return digest[7:]  # 移除 "sha256:" 前缀
    return None


def calculate_sha256_request(url: str):
    """计算远程文件的 SHA256 哈希值"""
    try:
        headers = {"Accept-Encoding": "identity"}
        response = requests.get(url, stream=True, headers=headers, timeout=30)
        response.raise_for_status()

        hasher = hashlib.sha256()
        for chunk in response.iter_content(chunk_size=8192):
            if chunk:
                hasher.update(chunk)

        return hasher.hexdigest()
    except Exception as e:
        logger.error(f"Error downloading {url}: {str(e)}")
        return None


def get_release_assets(owner, repo, tag=None):
    """获取仓库的 Release 资源"""
    try:
        token = os.environ.get("GITHUB_TOKEN")
        headers = {"Accept": "application/vnd.github.v3+json"}
        if token:
            headers["Authorization"] = f"token {token}"

        if tag:
            # 获取特定标签的 release
            release_url = (
                f"https://api.github.com/repos/{owner}/{repo}/releases/tags/{tag}"
            )
            response = requests.get(release_url, headers=headers, timeout=15)
            
            # Handle rate limit exceeded
            if response.status_code == 403 and "rate limit exceeded" in response.text.lower():
                logger.error(f"Network error fetching releases: {response.status_code} {response.reason}")
                logger.info("Skipping update due to GitHub rate limit")
                sys.exit(0)
            
            if response.status_code == 404:
                logger.warning(f"Release tag '{tag}' not found for {owner}/{repo}")
                return []
            response.raise_for_status()
            releases = [response.json()]
        else:
            # 只获取最新的 release
            latest_url = f"https://api.github.com/repos/{owner}/{repo}/releases/latest"
            response = requests.get(latest_url, headers=headers, timeout=15)

            # Handle rate limit exceeded
            if response.status_code == 403 and "rate limit exceeded" in response.text.lower():
                logger.error(f"Network error fetching releases: {response.status_code} {response.reason}")
                logger.info("Skipping update due to GitHub rate limit")
                sys.exit(0)

            # 处理没有 release 的情况
            if response.status_code == 404:
                logger.warning(f"No releases found for {owner}/{repo}")
                return []

            response.raise_for_status()
            releases = [response.json()]

        assets = []
        for release in releases:
            # 跳过草稿版 release
            if release.get("draft", False):
                logger.info(f"Skipping draft release: {release['tag_name']}")
                continue

            for asset in release.get("assets", []):
                # 只处理 gz/tar.gz 文件
                if asset["name"].lower().endswith((".tar.gz", ".gz")):
                    assets.append(
                        {
                            "name": asset["name"],
                            "url": asset["browser_download_url"],
                            "release_tag": release["tag_name"],
                            "digest": asset.get("digest", ""),
                        }
                    )

        logger.info(f"Found {len(assets)} assets in {len(releases)} releases")
        return assets

    except requests.exceptions.RequestException as e:
        logger.error(f"Network error fetching releases: {str(e)}")
        return []
    except Exception as e:
        logger.error(f"Unexpected error fetching releases: {str(e)}")
        return []


def generate_package_name(asset_name):
    """生成 Nix 包名"""
    # https://github.com/voidlhf/StarRailGrubThemes?tab=readme-ov-file#without-nixos-module
    base = re.sub(r"\.(tar\.gz|gz)$", "", asset_name, flags=re.IGNORECASE)
    clean = base.lower().replace(".", "_")
    name = f"{clean}"

    return name


def main():
    parser = argparse.ArgumentParser(description="Generate theme package info JSON")
    parser.add_argument("--owner", default="voidlhf", help="GitHub repository owner")
    parser.add_argument(
        "--repo", default="StarRailGrubThemes", help="GitHub repository name"
    )
    parser.add_argument("--tag", help="Specific release tag to process")
    parser.add_argument(
        "--output",
        default=os.path.join(os.path.dirname(os.path.abspath(__file__)), "themes.json"),
        help="Output JSON file path",
    )

    args = parser.parse_args()

    logger.info(f"Fetching releases for {args.owner}/{args.repo}")
    assets = get_release_assets(args.owner, args.repo, args.tag)
    logger.info(f"Found {len(assets)} .gz assets")

    theme_info = {}
    for asset in assets:
        pname = generate_package_name(asset["name"])
        logger.info(f"Processing: {pname}")

        # 优先使用API提供的SHA256，如果没有则下载计算
        sha256 = extract_sha256_from_digest(asset.get("digest", ""))
        if not sha256:
            logger.info(
                f"SHA256 not found in API for {pname}, falling back to download"
            )
            sha256 = calculate_sha256_request(asset["url"])

        if not sha256:
            logger.warning(f"Failed to get SHA256 for {pname}, skipping")
            continue

        theme_info[pname] = {
            "url": asset["url"],
            "sha256": sha256,
            "tag": asset.get("release_tag"),
        }

    # 保存到文件
    with open(args.output, "w") as f:
        json.dump(theme_info, f, indent=2, sort_keys=True)

    logger.info(f"Saved theme info to {args.output}")


if __name__ == "__main__":
    main()
