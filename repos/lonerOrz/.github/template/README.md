# Update Script 编写指南

本目录包含用于包更新的工具脚本和模板。

## 📁 文件说明

| 文件 | 用途 |
|------|------|
| `update.sh` | 更新脚本模板，复制到其他包目录后修改 |
| `github-tag-fetch.sh` | 获取 GitHub 最新 release tag |
| `github-rev-fetch.sh` | 获取 GitHub 分支最新 commit |
| `fetch-sri-hash.sh` | 一步获取 URL 的 SRI hash |

## ✅ 模板检查清单

编写 update 脚本时，请确保包含以下要素：

- [ ] 使用 `set -euo pipefail`
- [ ] 定义 `SCRIPT_DIR` 并使用绝对路径引用工具脚本
- [ ] 配置包信息（owner/repo/pname 或 PKG_FILE/BUILD_TARGET）
- [ ] 创建备份并设置 `trap rollback EXIT`
- [ ] 使用工具脚本获取版本/commit（避免重复造轮子）
- [ ] 检查是否需要更新（避免无意义运行）
- [ ] 使用 dummy hash + 构建获取真实 hash（多 hash 场景）
- [ ] 成功后 `trap - EXIT` 并清理备份
- [ ] 最终验证构建（可选但推荐）

## 🔄 标准更新流程

一个完整的更新脚本应包含以下阶段：

### 1️⃣ 初始化配置

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_FILE="$SCRIPT_DIR/default.nix"

# 包信息
OWNER="owner"
REPO="repo"
PNAME="package-name"
```

### 2️⃣ 获取最新版本/commit

**使用 release tag：**
```bash
latest_version=$("$SCRIPT_DIR/../../.github/script/github-tag-fetch.sh" "${OWNER}/${REPO}")
latest_version="${latest_version#v}"  # 去掉 v 前缀
```

**使用 git commit：**
```bash
latest_rev=$("$SCRIPT_DIR/../../.github/script/github-rev-fetch.sh" "${OWNER}/${REPO}")
```

**使用 npm version：**
```bash
latest_version=$(npm view @scope/package version)
```

### 3️⃣ 检查是否需要更新

```bash
current_version=$(grep -oP 'version\s*=\s*"\K[^"]+' "$PACKAGE_FILE")

if [[ "$latest_version" == "$current_version" ]]; then
    echo "✅ Already up to date"
    exit 0
fi

echo "⬆️ Update: $current_version -> $latest_version"
```

### 4️⃣ 回退机制（必需）

```bash
# 创建备份
backup=$(mktemp)
cp "$PACKAGE_FILE" "$backup"

# 设置回退 trap
rollback() {
    echo "❌ Update failed, rolling back..." >&2
    cp "$backup" "$PACKAGE_FILE"
    rm -f "$backup"
}
trap rollback EXIT

# ... 更新逻辑 ...

# 成功后禁用回退
trap - EXIT
rm -f "$backup"
echo "✅ Update completed"
```

### 5️⃣ 更新版本号

```bash
sed -i -E "s|(version\s*=\s*\")[^\"]+(\")|\1${latest_version}\2|" "$PACKAGE_FILE"
```

### 6️⃣ 获取 Hash（核心步骤）

#### 方法 A：直接使用 `fetch-sri-hash.sh`（推荐）

适用于简单场景（单个 URL）：

```bash
# 二进制文件（.deb, .AppImage）- 不解压
hash=$("$SCRIPT_DIR/../../.github/script/fetch-sri-hash.sh" "$url")

# Tarball（需要解压）
hash=$("$SCRIPT_DIR/../../.github/script/fetch-sri-hash.sh" "$url" --unpack)
```

#### 方法 B：Dummy Hash + 构建获取（适用于多 hash）

```bash
DUMMY_HASH="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

# 1. 设置 dummy hash
sed -i "s|hash = \".*\";|hash = \"$DUMMY_HASH\";|" "$PACKAGE_FILE"

# 2. 构建并捕获 hash mismatch
log=$(mktemp)
if nix build ".#$PNAME" 2>"$log"; then
    echo "Build succeeded unexpectedly" >&2
    exit 1
fi

# 3. 提取真实 hash
new_hash=$(grep -oP 'got:\s*\Ksha256-[A-Za-z0-9+/=]+' "$log" | head -n1)
rm -f "$log"

# 4. 替换
sed -i "s|$DUMMY_HASH|$new_hash|" "$PACKAGE_FILE"
```

#### 方法 C：多 hash 顺序获取

```bash
HASH_KEYS=(hash cargoHash vendorHash)

for key in "${HASH_KEYS[@]}"; do
    # 设置 dummy
    sed -i -E "s|(${key}\s*=\s*\")[^\"]*(\")|\1${DUMMY_HASH}\2|" "$PACKAGE_FILE"
    
    # 构建获取
    log=$(mktemp)
    nix build ".#$PNAME" 2>"$log" || true
    new_hash=$(grep -oP 'got:\s*\Ksha256-[A-Za-z0-9+/=]+' "$log" | head -n1)
    rm -f "$log"
    
    # 替换
    sed -i -E "s|(${key}\s*=\s*\")${DUMMY_HASH}(\")|\1${new_hash}\2|" "$PACKAGE_FILE"
done
```

### 7️⃣ 最终验证（可选）

```bash
echo "🏁 Final verification..."
nix build ".#$PNAME" --no-link
```

## 📝 完整示例

### 示例 1：简单 GitHub Release

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_FILE="$SCRIPT_DIR/default.nix"

OWNER="example"
REPO="app"
PNAME="app"

# 获取最新版本
latest_version=$("$SCRIPT_DIR/../../.github/script/github-tag-fetch.sh" "${OWNER}/${REPO}")
latest_version="${latest_version#v}"

current_version=$(grep -oP 'version\s*=\s*"\K[^"]+' "$PACKAGE_FILE")

if [[ "$latest_version" == "$current_version" ]]; then
    echo "✅ Already up to date"
    exit 0
fi

echo "⬆️ Update: $current_version -> $latest_version"

# 备份 + 回退
backup=$(mktemp)
cp "$PACKAGE_FILE" "$backup"
trap 'cp "$backup" "$PACKAGE_FILE"; rm -f "$backup"' EXIT

# 更新 version
sed -i -E "s|(version\s*=\s*\")[^\"]+(\")|\1${latest_version}\2|" "$PACKAGE_FILE"

# 获取 hash
url="https://github.com/${OWNER}/${REPO}/releases/download/v${latest_version}/${REPO}-${latest_version}.tar.gz"
hash=$("$SCRIPT_DIR/../../.github/script/fetch-sri-hash.sh" "$url" --unpack)

# 更新 hash
sed -i -E "s|(hash\s*=\s*\")[^\"]+(\")|\1${hash}\2|" "$PACKAGE_FILE"

# 成功
trap - EXIT
rm -f "$backup"
echo "✅ Update completed"
```

### 示例 2：Git Commit + 多 Hash

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_FILE="$SCRIPT_DIR/default.nix"

OWNER="example"
REPO="rust-app"
PNAME="rust-app"

DUMMY_HASH="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

# 备份 + 回退
backup=$(mktemp)
cp "$PACKAGE_FILE" "$backup"
rollback() {
    echo "Rolling back..." >&2
    cp "$backup" "$PACKAGE_FILE"
}
trap rollback EXIT

# 获取最新 commit
latest_rev=$("$SCRIPT_DIR/../../.github/script/github-rev-fetch.sh" "${OWNER}/${REPO}")
current_rev=$(grep -oP 'rev\s*=\s*"\K[^"]+' "$PACKAGE_FILE")

if [[ "$latest_rev" == "$current_rev" ]]; then
    echo "✅ Already up to date"
    exit 0
fi

echo "⬆️ Update: $current_rev -> $latest_rev"

# 更新 rev
sed -i -E "s|(rev\s*=\s*\")[^\"]+(\")|\1${latest_rev}\2|" "$PACKAGE_FILE"

# 逐个更新 hash
for key in hash cargoHash; do
    echo "🔧 Updating $key..."
    
    sed -i -E "s|(${key}\s*=\s*\")[^\"]*(\")|\1${DUMMY_HASH}\2|" "$PACKAGE_FILE"
    
    log=$(mktemp)
    if nix build ".#$PNAME" 2>"$log"; then
        echo "❌ Build succeeded unexpectedly" >&2
        exit 1
    fi
    
    new_hash=$(grep -oP 'got:\s*\Ksha256-[A-Za-z0-9+/=]+' "$log" | head -n1)
    rm -f "$log"
    
    if [ -z "$new_hash" ]; then
        echo "❌ Failed to extract hash" >&2
        exit 1
    fi
    
    sed -i -E "s|(${key}\s*=\s*\")${DUMMY_HASH}(\")|\1${new_hash}\2|" "$PACKAGE_FILE"
    echo "✅ $key = $new_hash"
done

trap - EXIT
rm -f "$backup"
echo "✅ Update completed"
```

## ⚠️ 注意事项

### 1. 路径问题

**所有脚本路径必须使用绝对路径**，根据脚本位置选择正确的相对路径：

```bash
# pkgs/xxx/update.sh -> .github/script/
"$SCRIPT_DIR/../../.github/script/github-tag-fetch.sh"

# .github/template/update.sh -> .github/script/
"$SCRIPT_DIR/../script/github-tag-fetch.sh"
```

### 2. Hash 格式

| 文件类型 | `fetch-sri-hash.sh` 参数 |
|----------|-------------------------|
| `.deb`, `.AppImage` | 不使用 `--unpack` |
| `.tar.gz`, `.tgz` | 使用 `--unpack` |
| Git archive | 使用 `--unpack` |

### 3. GITHUB_TOKEN

遇到 API 限流时，设置 `GITHUB_TOKEN` 环境变量：

```bash
GITHUB_TOKEN=your_token just update-custom-package mypackage
```

工具脚本会自动检测并使用 `GITHUB_TOKEN` 进行认证请求。

### 4. 禁用自动更新

对于无法自动更新的包（如本地 `src = ./.;`），在 `default.nix` 中添加：

```nix
passthru.autoUpdate = false;
```

`update-nix.py` 会跳过这些包。

### 5. pre_update_hook（可选）

某些包需要在更新 rev 之前执行预处理：

```bash
pre_update_hook() {
    # 例如：更新子模块
    git submodule update --init --recursive
}
```

在更新 rev 之前调用此钩子。

## 🛠️ 工具脚本说明

### github-tag-fetch.sh

```bash
# 用法
.github/script/github-tag-fetch.sh <owner/repo>

# 输出
v1.2.3

# 特性
# - 优先使用 GITHUB_TOKEN 认证（避免限流）
# - 失败时 fallback 到 git ls-remote
# - 自动验证结果
```

### github-rev-fetch.sh

```bash
# 用法
.github/script/github-rev-fetch.sh <owner/repo> [branch]

# 输出（示例）
ca1067afd8c1a3707f1aaf6eb64e980539945b43

# 特性
# - 默认 branch 为 main
# - 支持 GITHUB_TOKEN 认证
# - 失败时 fallback 到 git ls-remote
```

### fetch-sri-hash.sh

```bash
# 用法（二进制文件）
.github/script/fetch-sri-hash.sh <url>

# 用法（tarball）
.github/script/fetch-sri-hash.sh <url> --unpack

# 输出
sha256-xxxxx...

# 特性
# - 一步获取 SRI 格式 hash
# - 无需手动转换 base64
# - 支持 --unpack 用于需要解压的归档
```

## 🔧 调试技巧

### 1. 查看构建日志

```bash
log=$(mktemp)
if nix build ".#$PNAME" 2>"$log"; then
    # ...
fi
cat "$log"  # 查看完整日志
```

### 2. 提取 hash

```bash
grep -oP 'got:\s*\Ksha256-[A-Za-z0-9+/=]+' "$log" | head -n1
```

### 3. 测试单个步骤

```bash
# 测试 hash 获取
.github/script/fetch-sri-hash.sh "https://example.com/file.tar.gz" --unpack

# 测试版本检测
.github/script/github-tag-fetch.sh "owner/repo"
```

## 📚 参考

- [Nix hash 格式](https://nix.dev/manual/nix/stable/command-ref/new-cli/nix-store-hash.html)
- [fetchFromGitHub](https://nixos.org/manual/nixpkgs/stable/#fetchFromGitHub)
- [buildRustPackage](https://nixos.org/manual/nixpkgs/stable/#fetchRustCrate)
