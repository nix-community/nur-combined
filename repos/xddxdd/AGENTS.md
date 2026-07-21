# NUR 包创建规则

## 工作流程

- **持续更新文档**：每次根据用户建议修改包后，应将可推广的经验教训更新到本文档（AGENTS.md）中
- **提炼通用规则**：关注用户指出的模式、最佳实践和常见错误，将其转化为可应用于其他包的通用规则

## Nix 包定义规范

### 代码风格

- 除非明确要求，否则不要在创建的 Nix 定义中添加任何注释

### 最佳实践

- **保持二进制文件名与源码一致**：安装二进制文件时，使用与源码中相同的文件名，不要重命名
- **使用 versionCheckHook**：在可能的情况下，为包添加 `versionCheckHook` 以验证版本一致性。需要添加以下配置：
  - 在 `nativeInstallCheckInputs` 中添加 `versionCheckHook`
  - 设置 `doInstallCheck = true`
  - 如果程序需要特定参数来显示版本，设置 `versionCheckProgramArg`（如 `--version`）
- **不要禁用测试**：`doCheck` 默认启用，不需要设置 `doCheck = false`。仅当上游测试在 Nix 构建环境中确实无法通过时（如需要网络访问、需要特定硬件等），才应禁用测试
- **禁用测试时启用安装检查**：如果设置 `doCheck = false` 禁用测试，必须同时设置 `doInstallCheck = true` 以确保 `versionCheckHook` 正常工作
- **上游版本不一致处理**：当上游 Cargo.toml / package.json 等文件中的版本号与发布标签不一致时，可在 `postPatch` 中使用 `sed` 正则动态修正版本号，以使 `versionCheckHook` 正常工作
- **处理 execstack 标记**：打包上游二进制时如遇到 `cannot enable executable stack`，用 `execstack -c`（`pax-utils`）或 `patchelf --clear-execstack` 清理需要可执行栈的 ELF（常见于某些 `.so`）
- **使用顶层 Xorg 包**：Xorg 相关的库和工具现在可以直接作为顶层包引用，不要使用 `xorg.` 前缀。例如使用 `libX11` 而不是 `xorg.libX11`，使用 `xcbutilimage` 而不是 `xorg.xcbutilimage`
- **不要使用已弃用的 `system` 属性**：在 NixOS 26.05+ 中，`pkgs.system` 已被弃用，访问时会触发 `evaluation warning: 'system' has been renamed to/replaced by 'stdenv.hostPlatform.system'`。获取当前系统平台时应使用 `stdenv.hostPlatform.system`（或 `final.stdenv.hostPlatform.system`、`prev.stdenv.hostPlatform.system`）。特别注意 `callPackage` 会从 pkgs 作用域自动注入参数，因此辅助函数若声明了 `{ system, ... }` 参数，实际会访问到已弃用的 `pkgs.system`，应改为声明 `{ stdenv, ... }` 并在函数内部用 `let system = stdenv.hostPlatform.system; in` 派生
- **扁平打包的二进制压缩包**：当上游 tarball 不包含单一顶层目录（直接在 `./` 下展开文件）时，stdenv 默认 `unpackPhase` 会报 `unpacker produced multiple directories`。此时需设置 `sourceRoot = "."`，让构建在解压根目录进行。
- **structuredAttrs 下修改 patches 列表**：当 `structuredAttrs is enabled` 时，不能在 `prePatch` 中通过修改 `patches` 变量来过滤补丁（`concatTo` 无法正确解析被修改后的字符串变量）。应改为完全覆盖 `patchPhase`，在其中用 `concatTo patchesArray patches` 读取补丁列表后自行过滤和应用。
- **setuptools 82+ 移除了 `pkg_resources`**：老版本的 XStatic 等包在 `xstatic/__init__.py` 和 `xstatic/pkg/__init__.py` 中使用 `__import__('pkg_resources').declare_namespace(__name__)`，在 setuptools 82+ 中会报 `ModuleNotFoundError: No module named 'pkg_resources'`。修复方法：在 `postPatch` 中用 `substituteInPlace` 删除该调用，同时用 `sed` 从 `setup.py` 中删除 `namespace_packages` 行。
- **Node.js 服务端应用写入运行时文件到源码目录**：基于 thinkjs 等框架的 Node.js 服务端应用常将运行时缓存/日志写入源码旁的目录（如 thinkjs 的 `RUNTIME_PATH` 默认为 `ROOT_PATH/runtime`，而 `ROOT_PATH` 通常硬编码为 `__dirname`）。在 Nix 中源码位于只读 store，会导致写入失败崩溃。修复方法：用补丁修改入口文件，将运行时路径改为从环境变量读取，默认指向可写位置（如 `process.env.XXX_RUNTIME_PATH || path.join(require('node:os').tmpdir(), 'xxx')`），保持 `ROOT_PATH`/`APP_PATH` 指向 store 以加载源码。优先使用独立补丁文件（`patches = [ ./xxx.patch ]`）而非 `substituteInPlace` 内联替换，便于审阅与维护。

## 包元数据规范

### meta.description（包描述）

- **必须设置**：所有包都必须包含 `meta.description` 字段
- **无首尾空格**：描述文本首尾不得包含空格
- **无冠词开头**：不得以冠词（a、an、the）开头
- **首字母大写**：描述必须以大写字母开头
- **无句号结尾**：描述末尾不得包含句号
- **单句描述**：描述应简短，只包含一个句子（不得包含 `.` 分隔的多个句子）
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
- **自动处理 v 前缀**：现有基础设施会自动从 nvfetcher 生成的版本号中移除 `v` 前缀，无需手动使用 `lib.removePrefix` 处理
- **Git 提交哈希格式**：如果使用 Git 提交哈希作为版本，应使用类似 `unstable-2020-01-01` 的日期格式，而不是 40 位哈希值

### 构建阶段钩子

对于自定义的构建阶段（`unpackPhase`、`patchPhase`、`configurePhase`、`buildPhase`、`installPhase`、`fixupPhase`），必须包含相应的钩子：

- 每个阶段的开头必须包含 `runHook pre<阶段名>`（如 `runHook preInstall`）
- 每个阶段的结尾必须包含 `runHook post<阶段名>`（如 `runHook postInstall`）
- 构建脚本中不得包含多余的反斜杠（如 `\\\n\n`）

### meta.mainProgram（主程序）

- **有 bin 目录时必须设置**：如果包安装了 `bin` 目录，必须设置 `meta.mainProgram`
- **主程序必须存在**：设置的主程序名必须在 `bin` 目录中实际存在

## AppImage 包

### 最佳实践

- **只提取一次 AppImage**：在 `let` 绑定中定义 `contents` 变量，在整个包定义中重复使用
- **重用现有桌面文件**：AppImage 通常包含桌面文件和图标，应该重用而不是手动创建
- **使用 extraInstallCommands**：通过 `extraInstallCommands` 安装桌面文件和图标
- **更新桌面文件路径**：使用 `substituteInPlace` 更新 `Exec` 和 `Icon` 字段以匹配 Nix 包装器名称

### 示例结构

```nix
let
  contents = appimageTools.extract {
    inherit (sources.package-name) pname version src;
  };
in
appimageTools.wrapType2 {
  inherit (sources.package-name) pname version src;

  extraInstallCommands = ''
    install -Dm644 ${contents}/app.desktop $out/share/applications/app.desktop
    substituteInPlace $out/share/applications/app.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=package-name' \
      --replace-fail 'Icon=AppIcon' 'Icon=app-icon'
    install -Dm644 ${contents}/app.png $out/share/pixmaps/app-icon.png
  '';
}
```

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
- `-f` 参数接受的是正则表达式，不是多个独立参数。要匹配多个包，使用正则如 `nvfetcher -f 'package-one|package-two'`
- 禁止运行不带包名的 `nvfetcher` 命令

### stable/unstable 双源模式

当一个包同时需要稳定版和跟踪上游 main 分支的 unstable 版时，使用以下命名约定：

- `package-name`：**unstable 源**（`src.git`），跟踪 git 主分支
- `package-name-stable`：**稳定源**（`src.github`），跟踪 GitHub Release

`helpers/nvfetcher-loader.nix` 会自动处理版本号：当 unstable 源的版本是 40 位哈希时，会查找对应的 `package-name-stable` 源获取最近稳定版号，生成 `最近稳定版-unstable-日期` 格式的版本号（如 `0.11.0-unstable-2026-07-10`）。

### GitHub 源码获取规则

根据以下条件选择相应的 `src` 类型：

1. **有最新发布版本**：使用 `src.github = "user/package"`
2. **无最新发布版本但有最新标签**：使用 `src.github_tag = "user/package"`
3. **既无发布版本也无标签**：使用 `src.git = "https://github.com/user/package.git"`

### GitHub 获取格式

- 从 GitHub 获取时，始终使用 `fetch.github = "user/package"` 格式
- 当 `fetch.github` 因 GitHub tag/release 歧义（HTTP 300 Multiple Choices）失败时，改用 `fetch.url = "https://github.com/user/package/archive/refs/tags/$ver.tar.gz"`

## 构建包

### 构建命令

- 使用 `nix build .#package-name` 构建包
- 只需指定包名本身，无需中间路径
- 示例：`pkgs/uncategorized/package-name` 应构建为 `nix build .#package-name`

## pnpm 前端构建

### fetchPnpmDeps 配置

- **必须设置 `fetcherVersion`**：`fetchPnpmDeps` 要求显式设置 `fetcherVersion`，推荐使用 `fetcherVersion = 3`
- **使用 `sourceRoot = "source/<子目录>"`**：当 `src` 来自 `fetchFromGitHub` 而项目在子目录中时，`sourceRoot` 需加 `source/` 前缀（如 `source/frontend`）
- **锁定 pnpm 版本**：当上游 lockfile 与最新 pnpm 版本不兼容时，通过 `pnpm = pnpm_10` 指定兼容的 pnpm 版本
- **`pnpmConfigHook` 自动安装依赖**：该钩子在 `postConfigure` 阶段自动运行 `pnpm install --offline --frozen-lockfile`，无需手动安装

### 多组件 pname 命名

- **每个派生使用不同的 pname**：对于包含多个派生（如前端依赖、前端构建产物、主程序）的包，每个派生的 `pname` 应添加不同的后缀加以区分
- **不要全局 inherit**：不要在 `let` 顶层写 `inherit (sources.xxx) version src;`，各派生应分别在自身作用域内通过 `inherit (sources.xxx) version src;` 获取所需字段

### Go + 前端项目

- **分开构建前端和 Go**：将前端构建为独立派生，在 `buildGoModule` 的 `preBuild` 中将构建产物复制到 Go embed 目录
- **复制到 embed 路径**：如果 Go 使用 `//go:embed` 嵌入前端产物，构建产物必须先放置到对应目录再执行 Go 编译
