# NUR 包创建规则

## Nix 包定义规范

### 代码风格

- 除非明确要求，否则不要在创建的 Nix 定义中添加任何注释

### 最佳实践

- **保持二进制文件名与源码一致**：安装二进制文件时，使用与源码中相同的文件名，不要重命名
- **使用 versionCheckHook**：在可能的情况下，为包添加 `versionCheckHook` 以验证版本一致性
- **禁用测试时启用安装检查**：如果设置 `doCheck = false` 禁用测试，必须同时设置 `doInstallCheck = true` 以确保 `versionCheckHook` 正常工作

## 包元数据规范

### meta.description（包描述）

- **必须设置**：所有包都必须包含 `meta.description` 字段
- **无首尾空格**：描述文本首尾不得包含空格
- **无冠词开头**：不得以冠词（a、an、the）开头
- **首字母大写**：描述必须以大写字母开头
- **无句号结尾**：描述末尾不得包含句号
- **单句描述**：描述应简短，只包含一个句子（不得包含 `. ` 分隔的多个句子）
- **不以包名开头**：描述不应以包名本身开头

### meta.license（许可证）

- **必须设置**：所有包都必须设置 `meta.license` 字段

### meta.maintainers（维护者）

- **必须设置**：所有新包都必须设置 `meta.maintainers` 字段
- **必须为非空列表**：维护者必须是一个非空列表
- **包含 xddxdd**：维护者列表中必须包含 xddxdd（`github = "xddxdd"`）

### meta.homepage（主页）

- **必须设置**：所有包都必须设置 `meta.homepage` 字段
- **自动补全**：对于使用 nvfetcher 的 GitHub 项目（`fetch.github`），如果未设置 homepage，工具会自动添加

### meta.changelog（更新日志）

- **自动补全**：对于使用 nvfetcher 的 GitHub Release（`src.github`），如果未设置 changelog，工具会自动添加指向 releases 页面的链接

### version（版本号）

- **无 v 前缀**：版本号不应以 `v` 开头
- **Git 提交哈希格式**：如果使用 Git 提交哈希作为版本，应使用类似 `unstable-2020-01-01` 的日期格式，而不是 40 位哈希值

### 构建阶段钩子

对于自定义的构建阶段（`unpackPhase`、`patchPhase`、`configurePhase`、`buildPhase`、`installPhase`、`fixupPhase`），必须包含相应的钩子：

- 每个阶段的开头必须包含 `runHook pre<阶段名>`（如 `runHook preInstall`）
- 每个阶段的结尾必须包含 `runHook post<阶段名>`（如 `runHook postInstall`）
- 构建脚本中不得包含多余的反斜杠（如 `\\\n\n`）

### meta.mainProgram（主程序）

- **有 bin 目录时必须设置**：如果包安装了 `bin` 目录，必须设置 `meta.mainProgram`
- **主程序必须存在**：设置的主程序名必须在 `bin` 目录中实际存在

## 包文件管理

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
