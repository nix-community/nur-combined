# NUR 包创建规则

## Nix 包定义规范

### 代码风格

- 除非明确要求，否则不要在创建的 Nix 定义中添加任何注释

### 最佳实践

- **保持二进制文件名与源码一致**：安装二进制文件时，使用与源码中相同的文件名，不要重命名
- **使用 versionCheckHook**：在可能的情况下，为包添加 `versionCheckHook` 以验证版本一致性

### 包文件管理

- 只需创建包定义文件本身，无需添加到全局列表
- 现有基础设施会自动识别新包
- 创建任何新文件后，必须运行 `git add` 将文件添加到 Git 暂存区，以便 Nix 可见

## 源码管理

### nvfetcher 使用

- 本仓库使用 nvfetcher 管理源码版本更新
- 配置文件位于 `nvfetcher.toml`

### 更新源码

- 修改 `nvfetcher.toml` 后运行 nvfetcher 时，必须指定包名：`nvfetcher -f package-name`
- 禁止运行不带包名的 `nvfetcher` 命令

### GitHub 源码获取规则

根据以下条件选择相应的 `src` 类型：

1. **有最新发布版本**：使用 `src.github = "user/package"`
2. **无最新发布版本但有最新标签**：使用 `src.github_tag = "user/package"`
3. **既无发布版本也无标签**：使用 `src.git = "https://github.com/user/package.git"`

### GitHub 获取格式

- 从 GitHub 获取时，始终使用 `fetch.github = "user/package"` 格式

## 构建包

### 构建命令

- 使用 `nix build .#package-name` 构建包
- 只需指定包名本身，无需中间路径
- 示例：`pkgs/uncategorized/package-name` 应构建为 `nix build .#package-name`
