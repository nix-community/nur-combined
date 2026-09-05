# NUR 包创建规则

## 工作流程

- **持续更新文档**：每次根据用户建议修改包后，应将可推广的经验教训更新到本文档（AGENTS.md）中
- **提炼通用规则**：关注用户指出的模式、最佳实践和常见错误，将其转化为可应用于其他包的通用规则

## Nix 包定义规范

### 代码风格

- 除非明确要求，否则不要在创建的 Nix 定义中添加任何注释

### 最佳实践

- **优先使用 finalAttrs 而非 rec**：新包一律写成 `stdenv.mkDerivation (finalAttrs: { ... })`（或 `buildPythonPackage (finalAttrs: { ... })` 等 mkDerivation 风格构建器的等价形式），不用 `rec`；包内自引用统一用 `finalAttrs.<attr>`。src 的 URL/tag 中出现版本号字面量时改用 `${finalAttrs.version}` 插值——nix-update 只对 `version = "..."` 行做文本替换，插值 URL 会随 version 属性自动更新。注意：`writeShellApplication`、`appimageTools.wrapType2/extract` 等不接受 functor 参数的构建器不能这样转换；纯 `.overrideAttrs` 包装文件与 sources.json 多源包无版本字面量可引用，保持原样
- **保持二进制文件名与源码一致**：安装二进制文件时，使用与源码中相同的文件名，不要重命名
- **使用 versionCheckHook**：在可能的情况下，为包添加 `versionCheckHook` 以验证版本一致性。需要添加以下配置：
  - 在 `nativeInstallCheckInputs` 中添加 `versionCheckHook`
  - 设置 `doInstallCheck = true`
  - 如果程序需要特定参数来显示版本，设置 `versionCheckProgramArg`（如 `--version`）
- **不要禁用测试**：`doCheck` 默认启用，不需要设置 `doCheck = false`。仅当上游测试在 Nix 构建环境中确实无法通过时（如需要网络访问、需要特定硬件等），才应禁用测试
- **禁用测试时启用安装检查**：如果设置 `doCheck = false` 禁用测试，必须同时设置 `doInstallCheck = true` 以确保 `versionCheckHook` 正常工作
- **上游版本不一致处理**：当上游 Cargo.toml / package.json 等文件中的版本号与发布标签不一致时，可在 `postPatch` 中使用 `sed` 正则动态修正版本号，以使 `versionCheckHook` 正常工作
- **处理 execstack 标记**：打包上游二进制时如遇到 `cannot enable executable stack`，用 `execstack -c`（`pax-utils`）或 `patchelf --clear-execstack` 清理需要可执行栈的 ELF（常见于某些 `.so`）
- **.NET 单文件（PublishSingleFile）自包含预编译二进制**：上游以 `dotnet publish -p:PublishSingleFile=true` 产出的自包含 ELF（如 Cleanuparr）把 .NET 运行时与托管程序集作为**裸数据追加在 ELF 段之后**（文件可达数百 MB）。打包时有三个坑：(1) 默认 `stripPhase` 会把追加在 ELF 之后的 bundle 当作非 ELF 数据截掉，把几百 MB 的可执行文件削成十几 MB 的废桩，必须设 `dontStrip = true`（`buildDotnetModule` 已默认设）；(2) `autoPatchelfHook` / `patchelf --set-rpath` 会重写 ELF section 布局，破坏追加 bundle 的偏移，运行时报 `Failure processing application bundle; possible file corruption. Arithmetic overflow while reading bundle.`，因此**不能使用 autoPatchelfHook**，只能用 `patchelf --set-interpreter` 单独改解释器（该操作不挪动 section，不破坏 bundle），运行时库改用 `makeWrapper --prefix LD_LIBRARY_PATH` 注入；(3) 运行时依赖通常需要 `stdenv.cc.cc.lib`（libstdc++）、`icu`（缺失时报 `Couldn't find a valid ICU package installed on the system`）、`openssl`（缺失时报 `No usable version of libssl was found` 并 core dump）。此外这类应用常把配置/日志目录默认放在 `AppContext.BaseDirectory`（即只读 store 里的 exe 旁），需在 wrapper 里通过上游提供的环境变量重定向到可写位置（如 Cleanuparr 的 `CLEANUPARR_CONFIG_PATH`，用 `makeWrapper --run 'export XXX="''${XXX:-''${XDG_CONFIG_HOME:-$HOME/.config}/pkg}"'` 设默认值，保留用户覆盖能力）
- **从源码构建 .NET 项目（buildDotnetModule）**：优先用 nixpkgs `buildDotnetModule` 从源码构建而非打预编译二进制。.NET 10 用 `dotnet-sdk = dotnetCorePackages.sdk_10_0`、`dotnet-runtime = dotnetCorePackages.runtime_10_0`；自包含单文件设 `selfContainedBuild = true` + `dotnetFlags = [ "-p:PublishSingleFile=true" ]`。NuGet 依赖锁文件用 `passthru.fetch-deps` 生成：派生里写 `nugetDeps = ./nuget-deps.json;`（先放占位 `[]`），构建后**直接执行生成的脚本文件**（`/nix/store/...-<pkg>-fetch-deps`），不要用 `nix run .#<pkg>.fetch-deps`——后者按 `meta.mainProgram` 找 `bin/<mainProgram>`，而 writeShellScript 产物是单文件无 `bin/` 目录，会报 `Not a directory`；脚本默认 depsFile 可能解析成只读 store 副本，需显式传工作区文件路径作第一个参数：`/nix/store/...-fetch-deps "$(pwd)/nuget-deps.json"`。**上游私有 NuGet 包（仅发布到 GitHub Packages 需认证）的处理**：先确认其源码是否公开（常有公开 fork 仓库），若公开则在 `postPatch` 里把 fork 源码拷进源码树，用 `substituteInPlace` 把 `<PackageReference Include="X" Version="Y" />` 替换成 `<ProjectReference Include="../path/to/fork.csproj" />`，这样 restore/build 完全走公开 NuGet，无需认证、无需为每个私有包单独 `packNupkg`+生成 deps；记得把 fork csproj 里的 `<GeneratePackageOnBuild>true</GeneratePackageOnBuild>` 改成 false 避免构建期打包。`buildDotnetModule` 的 `projectReferences`（配合 `packNupkg=true`）是另一条路但要求 nupkg 版本与 `PackageReference` 完全一致、且每个 nupkg 都要单独跑 fetch-deps，比 ProjectReference 替换法繁琐。**makeWrapperArgs 注意**：dotnet-hook 在非 structuredAttrs 时用 `makeWrapperArgs=( ${makeWrapperArgs-} )` 做不安全词分割，会把含空格的 `--run 'export ...'` 拆成多个参数报 `makeWrapper doesn't understand the arg`，需设 `__structuredAttrs = true` 保留数组；makeWrapperArgs 里的 `$out` 不会被运行时展开（makeWrapper 把它当字面量嵌入），要引用输出路径必须用 `${placeholder "out"}` 让 Nix 在求值期替换。**executables 必须显式指定**：否则 hook 的 `find $installPath ! -name "*.dll" -executable -type f` 会把随附的 `libe_sqlite3.so`/`libMono.Unix.so` 等带可执行位的 .so 也包进 `bin/`；设 `executables = [ "<AssemblyName>" ]` 只包主程序，wrapper 名取 exe basename（大小写敏感），可用 `postFixup = ''ln -s <ExeName> $out/bin/<lowercase>''` 提供 `meta.mainProgram` 对应的小写命令。前端（Angular/npm）单独用 `buildNpmPackage` 构建（`nodejs = nodejs_26`，`npmDepsHash` 用 `prefetch-npm-deps package-lock.json` 算），在 `postPatch` 把其 `wwwroot` 拷到主项目的 `wwwroot/` 目录，使 `dotnet publish` 把静态文件作为 static web assets 一并产出
- **预编译 npm 包（buildNpmPackage + dontNpmBuild）的三个坑**：(1) 依赖树中有自带 `npm-shrinkwrap.json` 的包（如 `@earendil-works/pi-coding-agent`）时，npm 会在父 lockfile 中为 shrinkwrap 子树记录**无 integrity 的嵌套条目**，Rust 版 `prefetch-npm-deps` 解析时直接 panic（`non-git dependencies should have associated integrity`）。修复：lockfile 生成脚本里用 Python 下载各条目的 `resolved` URL 计算并注入 `sha512-` integrity（无 `resolved` 的 `inBundle` dev 条目可跳过，prefetch 能容忍）。(2) 生成 lockfile 必须用真实 `npm install --ignore-scripts`（含 `--package-lock-only` 会漏掉部分平台 optional 依赖，如 `@img/sharp-win32-x64`，导致 `npm ci` 报 `Missing: ... from lock file`）。(3) npm 的 make-fetch-happen 在按 URL 查缓存时（用于**无 integrity** 的 fetch，如 shrinkwrap 子树）会调用 `cacache.index.compact()` 往缓存写临时文件，而 npmDeps 缓存挂载在只读 store 上（`mkdir .../tmp` 失败 → `ENOTCACHED`；带 integrity 的 fetch 走 byDigest 纯读路径不受影响）。修复：设 `makeCacheWritable = true`（npmConfigHook 会把缓存复制到可写目录，代价是每次构建多拷几百 MB）。`prefetch-npm-deps` 缓存布局为 `<npmDeps>/_cacache/{index-v5,content-v2/sha512}`，与 npm 的 `flatOptions.cache = <cache>/_cacache` 一致，无需额外处理。**上游仓库 lockfile 不可直接复用**（如 pi-web）：npm registry tarball 不含 lockfile，上游 GitHub 仓库虽提交了 `package-lock.json`，但它是 bun（`bun.lock` 为主锁）环境下的次要产物——既有无 integrity 的 shrinkwrap 嵌套条目（仍需 Python 注入），又混入 bun 转换残留包（`confbox`/`mlly`/`pathe`/`pkg-types`/`ufo`）并缺少新版平台 optional 依赖（如 `@unrs/resolver-binding-linux-loong64-gnu`），一旦与 `package.json` 失步 `npm ci` 直接报错；应从发布 tarball 的 `package.json` 用真实 `npm install` 自行生成。**生成式 lockfile 包的更新脚本整合**（如 pi-web）：不要再同时挂 `nix-update-script` passthru 与 `update-standalone.sh` 双机制——顶层 `update` 命令先跑 `update-standalone.*` 后跑 `update-package --all`，lockfile 会按旧版本重生成、随后 nix-update 只改版本号留下失步的 `npmDepsHash`。正确做法是单一 `update.sh`（`passthru.updateScript = [ (toString ./update.sh) ];`）：先 `nix-update "$UPDATE_NIX_ATTR_PATH" --version "$(npm view <pkg> version)" --src-only` 更新版本与 src 哈希（`--src-only` 跳过 npmDepsHash，否则 nix-update 会对旧 lockfile 跑 `npm ci` 失败中止），再从新 src 重生成 lockfile、注入 integrity、用 `prefetch-npm-deps` 回写 `npmDepsHash`
- **使用顶层 Xorg 包**：Xorg 相关的库和工具现在可以直接作为顶层包引用，不要使用 `xorg.` 前缀。例如使用 `libX11` 而不是 `xorg.libX11`，使用 `xcbutilimage` 而不是 `xorg.xcbutilimage`
- **不要使用已弃用的 `system` 属性**：在 NixOS 26.05+ 中，`pkgs.system` 已被弃用，访问时会触发 `evaluation warning: 'system' has been renamed to/replaced by 'stdenv.hostPlatform.system'`。获取当前系统平台时应使用 `stdenv.hostPlatform.system`（或 `final.stdenv.hostPlatform.system`、`prev.stdenv.hostPlatform.system`）。特别注意 `callPackage` 会从 pkgs 作用域自动注入参数，因此辅助函数若声明了 `{ system, ... }` 参数，实际会访问到已弃用的 `pkgs.system`，应改为声明 `{ stdenv, ... }` 并在函数内部用 `let system = stdenv.hostPlatform.system; in` 派生
- **扁平打包的二进制压缩包**：当上游 tarball 不包含单一顶层目录（直接在 `./` 下展开文件）时，stdenv 默认 `unpackPhase` 会报 `unpacker produced multiple directories`。此时需设置 `sourceRoot = "."`，让构建在解压根目录进行。
- **structuredAttrs 下修改 patches 列表**：当 `structuredAttrs is enabled` 时，不能在 `prePatch` 中通过修改 `patches` 变量来过滤补丁（`concatTo` 无法正确解析被修改后的字符串变量）。应改为完全覆盖 `patchPhase`，在其中用 `concatTo patchesArray patches` 读取补丁列表后自行过滤和应用。
- **setuptools 82+ 移除了 `pkg_resources`**：老版本的 XStatic 等包在 `xstatic/__init__.py` 和 `xstatic/pkg/__init__.py` 中使用 `__import__('pkg_resources').declare_namespace(__name__)`，在 setuptools 82+ 中会报 `ModuleNotFoundError: No module named 'pkg_resources'`。修复方法：在 `postPatch` 中用 `substituteInPlace` 删除该调用，同时用 `sed` 从 `setup.py` 中删除 `namespace_packages` 行。
- **PyPI URL 必须带文件扩展名**：PyPI 的 `pypi.io/packages/source/<首字母>/<名>/<名>-<版本>` 路由已不再服务不带扩展名的 URL（返回 404，报 `cannot download ... from any mirror`），`mirror://pypi/...` 的 fetchurl URL 必须写成完整文件名（如 `<名>-<版本>.tar.gz`）。另外 PyPI 可能用归一化名称重新上传 sdist（如 `XStatic-Font-Awesome` 的 sdist 改名为 `xstatic_font_awesome-6.2.1.2.tar.gz`），此时需同步改 URL 并更新哈希；重新生成的 sdist 往往改用现代 setuptools（`find_namespace_packages`、无 `pkg_resources`），原有的 pkg_resources 相关 `postPatch` 补丁应一并删除。
- **pythonMetadataCheckPhase 与 pname 不一致**：新版 nixpkgs 的 `pythonMetadataCheckPhase` 钩子会用 `importlib.metadata.version($pname)` 校验已安装包元数据，要求派生 `pname` 与上游 PyPI 分发名（PEP 503 归一化）一致且版本合法相等。若派生 `pname` 与 PyPI 名不一致导致检查失败，把 `pname` 改为真实分发名；仅当 `version` 无法对齐时才用 `dontCheckPythonMetadata = true;` 关闭检查。
- **nixpkgs 依赖被 setuptools 上界约束打破**：当 nixpkgs 的某个 Python 依赖（如 `mfusepy`）在 `[build-system] requires` 中钉死 `setuptools < 83`，而 nixpkgs 已升级到 setuptools 83，构建期会报 `Unmet dependencies`。应在直接引用该依赖的包内就地覆盖，而不要在 `pkgs/python-packages/default.nix` 的 `self` 集合中全局覆盖：在该包定义里用 `let <pkg>' = <pkg>.overridePythonAttrs (old: { postPatch = (old.postPatch or "") + ''\n        substituteInPlace pyproject.toml --replace-fail 'setuptools >= 61, < 83' 'setuptools >= 61'\n      ''; }); in` 得到放宽约束的版本，并在依赖列表中使用 `<pkg>'`（务必拼接原有 `postPatch`，避免丢失既有补丁）。
- **上游补丁失效时的重新生成方法**：当上游源码结构变化（目录改名、CMakeLists 重构等）导致已有补丁 hunk 失败（`Hunk #N FAILED -- saving rejects`）时，不要手工改补丁上下文，而应在 `/tmp` 解包新源码，把同一套变换（sed/Python）应用到副本上，再用 `diff -u old new` 重新生成补丁（注意把 `--- old/`、`+++ new/` 前缀改回 `a/`、`b/`，并在副本上 `patch --dry-run` 验证）。同时必须检查上游是否新增了带有同类代码模式的文件：旧的 `qt6-qchar-fix.patch` 只覆盖了 `DeveloperComponents/` 下的文件，上游把该目录改名为 `Development` 并新增了多个文件后，同样的 `QChar(ElaIconType::X)` 编译错误出现在 `ElaIcon.cpp`（`QChar(awesome)`）、`ElaKeyBinder.cpp`、`ElaToolButton.cpp`（`QChar(icon)`）、`ElaText.cpp`（`QChar(d->_pElaIcon)`）、`ElaFooterDelegate.cpp`/`ElaNavigationStyle.cpp`（`QChar(node->getAwesome())`）等变量形式中，需一并覆盖（用 `static_cast<char16_t>(...)` 包住）；这些新增文件若未覆盖，patchPhase 过后会在编译期才报 `no matching function for call to 'QChar::QChar(ElaIconType::IconName&)'`。
- **上游 go.mod 要求比 nixpkgs 更新的 Go 补丁版本**：当 go.mod 声明 `go 1.26.6` 而 nixpkgs 默认 `go` 仍为 1.26.5 时，构建报 `go.mod requires go >= 1.26.6 (running go 1.26.5; GOTOOLCHAIN=local)`。修复：直接用版本绑定的 `buildGo127Module`（nixpkgs 为各 Go 主版本提供 `buildGo12XModule`，等价于 `buildGoModule.override { go = go_1_27; }`，比 override 更简洁）作为构建器。仓库锁定的 nixpkgs 中 `go_1_27` 可能是 1.27rc3，仍满足 `>= 1.26.6` 即可用；用 `nix eval --raw .#packages.<system>.<pkg>.go.version` 可确认实际生效的 Go 版本。
- **Node.js 服务端应用写入运行时文件到源码目录**：基于 thinkjs 等框架的 Node.js 服务端应用常将运行时缓存/日志写入源码旁的目录（如 thinkjs 的 `RUNTIME_PATH` 默认为 `ROOT_PATH/runtime`，而 `ROOT_PATH` 通常硬编码为 `__dirname`）。在 Nix 中源码位于只读 store，会导致写入失败崩溃。修复方法：用补丁修改入口文件，将运行时路径改为从环境变量读取，默认指向可写位置（如 `process.env.XXX_RUNTIME_PATH || path.join(require('node:os').tmpdir(), 'xxx')`），保持 `ROOT_PATH`/`APP_PATH` 指向 store 以加载源码。优先使用独立补丁文件（`patches = [ ./xxx.patch ]`）而非 `substituteInPlace` 内联替换，便于审阅与维护。
- **为修改版 Firefox 关闭 PGO**：`buildMozillaMach` 默认在 x86_64-linux 上启用 PGO（`enablePGO` 默认在 Linux 且非交叉编译且 64 位时为 true；旧版 nixpkgs 中该参数名为 `pgoSupport`，现已被重命名为 `enablePGO`，`ltoSupport` 同样改名为 `enableLTO`），其 `profilingPhase` 会用 `./mach python ./build/pgo/profileserver.py` 启动一次 Firefox 采集 profile。但重度补丁版的 Firefox（如 `feder-cr/firefox_antidetect_patch` 的反指纹分支）会破坏内容进程的干净关闭：`Quitter.quit()` 触发的关闭过程中内容进程 hang，被进程监视器 SIGABRT，LLVM profile runtime 来不及 flush，导致 `llvm-profdata merge` 报 `truncated profile data` / `no profile can be merged`，整个 `profilingPhase` 失败（上游只跑 `./mach build`、从不测试 PGO）。修复方法：用 `.override { enablePGO = false; }` 关闭 PGO（LTO 仍由 `enableLTO` 默认开启，保留）。注意 `buildMozillaMach` 的 `enablePGO` 在其内部派生函数的参数里、不在外层 opts 里，因此不能直接写进 `buildMozillaMach { ... }`，而要用派生的 `.override` 传：`((buildMozillaMach { ... }).override { enablePGO = false; }).overrideAttrs (old: { ... })`。nixpkgs 升级若报 `function 'anonymous lambda' called with unexpected argument 'pgoSupport'` 且导致整个 flake 无法求值，就是此参数改名所致。
- **nginx 模块 `--add-module` 路径跟随上游目录结构**：OpenResty/nginx 自定义包的 `--add-module` 必须指向包含 `config` 文件的目录，上游重构目录后需同步更新，否则 configure 阶段报 `error: no .../config was found`。例如 ja4-nginx-module 把 `config` 从 `src/` 移到仓库根目录后，`--add-module=bundle/ja4-nginx-module/src` 需改为 `--add-module=bundle/ja4-nginx-module`（其 `config` 内部用 `$ngx_addon_dir/src/...` 引用源码，不受影响）。上游模块升级后若 configure 报找不到 `config`，先检查模块仓库中 `config` 文件的实际位置。
- **`.override` 后接 `.overrideAttrs` 必须加括号**：Nix 中属性选择 `.` 的优先级高于函数应用。`X.override { a = 1; } .overrideAttrs (...)` 会被解析为 `X.override ( ({a=1;}).overrideAttrs (...) )`，即对字面量 attrset `{a=1;}` 取 `.overrideAttrs`，报 `attribute 'overrideAttrs' missing`。必须写成 `(X.override { a = 1; }).overrideAttrs (...)`，用括号让 `.override` 先完整应用、再对其结果取 `.overrideAttrs`。

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

### meta.changelog（更新日志）


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

## updateScript 包更新机制（nixpkgs 风格）

### 概述

全部包均使用 nixpkgs 原生的 `passthru.updateScript` 更新机制或独立更新脚本，nvfetcher 相关基础设施（`nvfetcher.toml`、`_sources/`、`helpers/nvfetcher-loader.nix`、`tools/update_sources.py`、devshell 的 `nvfetcher`/`update-sources` 命令）已完全移除。包定义把 fetcher 内联在文件中，由 `helpers/update.nix` 统一发现并执行更新脚本。

### 多源包的 sources.json 模式

消费多个上游源的包（如 fr24feed、dbip-lite、qemu-user-static、qq、lantianCustomized.nginx）不要把版本/哈希字面量写死在 default.nix 里，而是：

1. 在包目录下维护 `sources.json`，每个条目含 `version`/`url`/`hash`（nginx 的 GitHub 模块条目为 `owner`/`repo`/`rev|tag`/`hash`/可选 `fetchSubmodules`）
2. default.nix 通过 `builtins.fromJSON (builtins.readFile ./sources.json)` 读取并构造 fetcher
3. 包目录下的 `update.sh` 负责探测新版本、用 `nix store prefetch-file --json [--unpack] <url>` 计算哈希（GitHub tarball 用 `--unpack`，其结果与 fetchFromGitHub 哈希一致），最后整体重写 `sources.json`
4. 注意：nix-update 只支持单一 `version`/`src` 属性，因此多源包必须走本模式；`sort -V` 是字典序，纯数字版本比较需按 `.` 分段转整数排序

### 版本约定

- **普通 GitHub release/tag**：直接 `nix-update-script { }`；v 前缀 tag（如 tag 为 `v1.2.0`、version 为 `1.2.0`）会被 nix-update 自动识别处理，无需额外参数
- **release 全是 beta/prerelease 的仓库**（如 axonhub，tag 全为 `v1.0.0-betaN`）：nix-update 默认 STABLE 偏好会拒绝更新，需 `nix-update-script { extraArgs = [ "--version" "unstable" ]; }`
- **GitHub releases 混入无关 tag 的仓库**（如 browseros，releases 里混着 `agent-server/v0.0.147`、`ext-*` 等扩展 tag）：加 `--version-regex` 过滤，如 `nix-update-script { extraArgs = [ "--version-regex" "^v([0-9.]+)$" ]; }`；nix-update 默认 regex 是 `(.*)`（整 tag 作为版本号）。**注意 atom feed 只列出最近约 10 个 release**：若无关 tag 频繁发布、把 feed 占满导致没有任何条目匹配 version-regex，nix-update 会直接抛 `VersionError: No version matched the regex` 使整个 CI 失败（而不是当作无更新跳过）——此时 regex 无法修复，必须改用自定义 `update.sh`：用 `git ls-remote --tags <url>` 获取完整 tag 列表，`sed -n 's#.*refs/tags/v\([0-9.]*\)$#\1#p'` 过滤（行尾锚定可自动排除 `^{}` peeled 引用），`sort -V | tail -1` 取最新，与 `$UPDATE_NIX_OLD_VERSION` 相等则 `exit 0`，否则 `nix-update "$UPDATE_NIX_ATTR_PATH" --version "$NEW_VERSION"`（参考 `pkgs/uncategorized/browseros/update.sh`）。注意验证时必须直接执行脚本（`bash -c /nix/store/...-update.sh`，与 CI 运行器一致）让 nix-shell shebang 生效，`bash script.sh` 会绕过 shebang 导致找不到 nix-update
- **不稳定包（`<tag>-unstable-<日期>` / `0-unstable-<日期>` 版本格式，跟踪 git HEAD）**：一律使用 nixpkgs `unstableGitUpdater`，不再用 `nix-update-script --version branch`：

  ```nix
  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/owner/repo";
    tagPrefix = "v";                # tag 为 vX.Y.Z 时剥离前缀，版本变 X.Y.Z-unstable-<日期>
    hardcodeZeroVersion = true;     # 无可用 tag（或 tag 非数字开头）时用 0-unstable-<日期>
    tagFormat = "[0-9]*";           # git describe --match 过滤无关 tag（如混入的 legacy/x86 tag）
    tagConverter = "sed s/^svn//";  # 复杂 tag 格式转换（输出必须以数字开头）
    shallowClone = false;           # 大仓库反复加深浅克隆会触发 git "shallow file has changed" 竞态（如 rtpengine）
  };
  ```

  机制与硬性要求：
  - **必须显式传 url**：省略时回退到 `nix-instantiate -E "with import ./. {}; $attr.src.gitRepoUrl"`，对根 `default.nix = import ./pkgs \"nur\"` 这种部分应用函数会直接报错，本仓库内不可用
  - 最终通过 `update-source-version` 改写文件：它从仓库根用 `nix-instantiate -A <attr>` 求值（根 default.nix 会被自动调用），因此包文件里必须存在字面量 `version = "...";`（全文唯一）、`rev = "<40位哈希>";`、`hash = "...";`，且 `meta.position` 必须指向该文件——**共享 generic.nix 之类的包（如 liboqs-unstable）必须写成独立文件**，否则 position 指向共享文件导致找不到哈希
  - 版本日期取 HEAD commit 的 committer date（`git show -s --pretty=format:%cs`），与 nix-update 用的 atom feed 日期可能相差一天
  - 已知坑：**同 rev 但版本串变化**（如日期漂移、前缀格式切换）时，`update-source-version` 在 rev 替换的 cmp 检查处 die，文件会残留 tempHash `sha256-AzH1rZFqEH8sovZZfJykvsEmCedEZWigQFHWHl6/PdE=` 与 `.nix.cmp` 备份——修复方法：版本行已是正确新值，把 hash 恢复为 git HEAD 里的原值（同 rev 同源同哈希），删掉 .cmp 后重跑（会以 same version 退出）
  - 仅支持 git 可 clone 的 URL；dpdk-kmods 只能 `git://dpdk.org/dpdk-kmods`（https 路径 cgit 不提供 smart HTTP）
  - 跟踪的 fork 分支可能比默认分支新（如 flaresolverr-alexfozor），首次运行版本回退属正常
  - `helpers/update.nix` 运行器原生支持 unstableGitUpdater 返回的列表形式 updateScript；`nvlax`（同文件多哈希）与 `qsp`（自定义多步 update.sh）不适用，保持原状
- **nix-update 的文件改写行为（源码已验证）**：`replace_version` 先定位 `version = "..."` 声明行；若该行包含旧版本字符串，则**只改写这一行**，其余行一律不动——因此 `url = ".../foo-1.2.3.tar.gz"` 这种内嵌版本字面量的 URL 永远不会被 nix-update 更新（版本号变了但 src 仍拉旧版，哈希不变，静默失败）。若 version 声明行不含旧版本字面量（如 `inherit version;`），则退化为全文件范围内把带引号的独立字符串 `"旧版本"` 整体替换成 `"新版本"`（仍只匹配独立带引号字符串，匹配不到 URL 内嵌片段）。rev/tag 则不同：nix-update 用求值出的旧 rev/tag 值在全文件做子串替换（release 模式与 `--version branch` 模式都携带新 rev/tag）。综上：**fetchurl 的 URL 必须用 `${finalAttrs.version}` 插值**；fetchFromGitHub 的 tag 也建议插值；rev 字面量可由 nix-update 自动维护，无需也无法插值
- **例外：自维护 URL 的 update.sh**：geolite2、netboot-xyz 的 update.sh 自己 grep + sed 重写 URL 与哈希，字面量 URL 是脚本的工作前提，不要改成插值；改动这两个包时保持 update.sh 与 URL 字面量同步修改
- **非 GitHub 源**（webpage 抓取、AUR 等）：手写自定义更新脚本。脚本必须作为独立文件放在包目录下（如 `pkgs/uncategorized/baidunetdisk/update.sh`），不要内联在 default.nix 中；在包定义里用 `passthru.updateScript = [ (toString ./update.sh) ];` 引用。运行器以仓库根目录为 cwd 执行脚本，并设置 `UPDATE_NIX_ATTR_PATH`/`UPDATE_NIX_PNAME`/`UPDATE_NIX_NAME`/`UPDATE_NIX_OLD_VERSION` 环境变量；脚本内部获取新版本号后调用 `nix-update "$UPDATE_NIX_ATTR_PATH" --version "$NEW_VERSION"`（参考 `pkgs/uncategorized/baidunetdisk/update.sh`）
- **nix-update 可自动识别的 fetchurl 源**：除了 GitHub releases，`registry.npmjs.org` 的 npm tarball URL 也能被 nix-update 自动探测最新版本（含 scoped 包），可直接用 `nix-update-script { }`
- **版本/src 在内层派生时需提升到顶层**：若 version 和 src 定义在 let 绑定的内层 `mkDerivation`（如 wine-wechat 的 wechatFiles），顶层求值结果没有 `src` 属性，nix-update 无法工作。重构方法：把 `version = "..."` 和 `src = fetchurl { ... }` 直接放在顶层 `stdenv.mkDerivation (finalAttrs: { ... })` 里（外层配 `dontUnpack = true` 即可，不影响构建）；内层派生通过 `inherit (finalAttrs) version src;` 引用同一份定义；原先依赖内层派生的 let 绑定（启动脚本等）移入使用它们的 phase（如 postInstall）内的局部 let。URL 用 `${finalAttrs.version}` 插值（见上条：字面量 URL 不会被 nix-update 改写）
- **多源同版本的去重**：同一文件里多个派生共享同一 GitHub 源（如 axonhub 的 frontendPnpmDeps/frontendDist/主程序、it-tools 的 pnpmDeps）时，在 let 里定义 `version = "...";` 与 `src = fetchFromGitHub { tag = "v${version}"; ... }`，各派生 `inherit version src;`，保证 nix-update 只需改一处版本字面量（`inherit version;` 行不含字面量时走全文件独立带引号串替换路径，let 绑定会被正确更新）
- **不要留孤儿 update.sh 副本**：只被 lockfile 再生成等辅助流程使用的脚本必须命名为 `update-standalone.*`；如果同时存在一份未被 `passthru.updateScript` 引用的同名 `update.sh`，它是死文件，应删除

### 运行方式

```bash
./tools/update-package foo [bar ...]   # 更新指定包（接受裸名或带组前缀）
./tools/update-package --path uncategorized  # 更新某组下所有包
./tools/update-package --all           # 更新全部已迁移包
```

也可通过 flake app 调用：`nix run .#update-pkg -- <参数>`。顶层 `update` 命令会自动执行 `update-package --all`。

### 脚本文件命名约定

- 包目录下的 `update.*`（如 `update.sh`）：passthru.updateScript 机制的新式更新脚本，由 `helpers/update.nix` 运行器发现并执行，不会被 `update` 命令的 find 循环执行。生成式 lockfile 包（如 pi-web）的更新脚本属于此类：脚本自身负责版本、src 哈希、lockfile 重生成与 `npmDepsHash` 的完整闭环（版本步用 `nix-update --src-only`），不要拆成 passthru + `update-standalone` 双机制（顶层 `update` 先跑 standalone 后跑 passthru，顺序会导致 lockfile 与版本失步）
- 包目录下的 `update-standalone.*`：旧的独立脚本（与版本更新无关的辅助流程），由顶层 `update` 命令的 find 循环直接执行，与 passthru 机制无关；不要用 `update.*` 命名这类脚本，避免被双重执行

### 已知限制

- 上游 git 子模块使用 SSH URL（如 `git@github.com:...`）的包无法被 nix-update 重新计算哈希；此类包应写独立 update.sh 自行计算哈希，或保持手动更新
- 包装类包（override nixpkgs 包、无独立 src，如 lantianCustomized.materialgram/firefox-unwrapped/attic-telnyx-compatible、uncategorized.wechat-uos-sandboxed/nftables-fullcone/libnftnl-fullcone）继承自 nixpkgs 的 updateScript 在本仓库无法正确运行，已在 `helpers/update.nix` 的 `excludes` 列表中排除，它们跟随 nixpkgs flake 锁更新
- python-packages 组的包因 nixpkgs `buildPythonPackage` 自动注入 `passthru.updateScript`，未迁移的包会被运行器的 `sources.` 过滤器跳过

## 源码管理

- 源码不再由集中式工具（nvfetcher）管理；每个包在自身目录内联 fetcher 并声明 `passthru.updateScript`
- 多源包使用 `sources.json` + `importJSON`/`fromJSON`（如 fr24feed、qemu-user-static、lantianCustomized.nginx），由包内 `update.sh` 整体重写
- 顶层 `update` 命令流程：`nix flake update` → 执行 `pkgs/**/update-standalone.*` → `./tools/update-package --all` → 重新生成 README

## 构建包

### 构建命令

- 使用 `nix build .#package-name` 构建包
- 包名是否带组前缀取决于包所在目录：`pkgs/uncategorized/` 下的包直接使用 `.#package-name`；`pkgs/asterisk-digium-codecs/`、`pkgs/kernel-modules/`、`pkgs/lantian-customized/`、`pkgs/python-packages/` 等分组目录下的包需带上组前缀
- 组前缀与目录名一一对应：`asteriskDigiumCodecs`、`kernel-modules`、`lantianCustomized`、`python3Packages`，可在 `pkgs/default.nix` 中查看全部分组
- 示例：`pkgs/uncategorized/package-name` 应构建为 `nix build .#package-name`；`pkgs/lantian-customized/ffmpeg` 应构建为 `nix build .#lantianCustomized.ffmpeg`；`pkgs/python-packages/mtkclient` 应构建为 `nix build .#python3Packages.mtkclient`
- 嵌套更深的包（如 asterisk 编解码器 `pkgs/asterisk-digium-codecs/` 下按版本分目录）需逐级引用：`nix build '.#asteriskDigiumCodecs."24".g729a'`

## pnpm 前端构建

### fetchPnpmDeps 配置

- **必须设置 `fetcherVersion`**：`fetchPnpmDeps` 要求显式设置 `fetcherVersion`。注意 `fetcherVersion = 3` 已不再支持 `pnpm_11`（会报 `fetcherVersion = 3 is no longer supported for pnpm_11`），使用 `pnpm_11` 时必须改用 `fetcherVersion = 4`（将 SQLite 数据库导出为 SQL 文件）；仅在仍使用 `pnpm_10` 等旧版本时才用 `fetcherVersion = 3`
- **Vite 静态站点的子目录部署**：上游通过 `process.env.BASE_URL` 控制的 Vite 静态站点（如 it-tools），可在包定义中暴露 `baseUrl ? "/"` 参数并设置 `env.BASE_URL = baseUrl`，构建后用户通过 `it-tools.override { baseUrl = "/it-tools/"; }` 即可生成适配子目录运行的产物
- **使用 `sourceRoot = "source/<子目录>"`**：当 `src` 来自 `fetchFromGitHub` 而项目在子目录中时，`sourceRoot` 需加 `source/` 前缀（如 `source/frontend`）
- **锁定 pnpm 版本**：当上游 lockfile 与最新 pnpm 版本不兼容时，通过 `pnpm = pnpm_10` 指定兼容的 pnpm 版本
- **`pnpmConfigHook` 自动安装依赖**：该钩子在 `postConfigure` 阶段自动运行 `pnpm install --offline --frozen-lockfile`，无需手动安装

### 多组件 pname 命名

- **每个派生使用不同的 pname**：对于包含多个派生（如前端依赖、前端构建产物、主程序）的包，每个派生的 `pname` 应添加不同的后缀加以区分
- **不要全局 inherit**：不要在 `let` 顶层写 `inherit (sources.xxx) version src;`，各派生应分别在自身作用域内通过 `inherit (sources.xxx) version src;` 获取所需字段

### Go + 前端项目

- **分开构建前端和 Go**：将前端构建为独立派生，在 `buildGoModule` 的 `preBuild` 中将构建产物复制到 Go embed 目录
- **复制到 embed 路径**：如果 Go 使用 `//go:embed` 嵌入前端产物，构建产物必须先放置到对应目录再执行 Go 编译

## Lockfile 与 update.sh

### 生成式 Lockfile

- **何时需要**：当上游使用 nixpkgs 不直接支持的 lockfile（如 `bun.lock`）但构建需要 `package-lock.json` / `pnpm-lock.yaml` 等 lockfile 时，应在包目录下提交一个生成式 lockfile（如 `package-lock.json`），并在派生的 `postPatch` 中复制到源码中
- **必须配套 update.sh**：每次提交生成式 lockfile 时，必须在其旁边创建 `update.sh` 脚本，用于在上游版本更新后重新生成 lockfile 及相关哈希（如 `npmDepsHash`），以便后续自动更新
- **update.sh 职责**：脚本应从包的内联 fetcher 源码（如 `nix eval --raw .#package.src`）获取源码，运行对应包管理器生成 lockfile，再计算并写回派生中的哈希

### update.sh 脚本规范

- **使用 `#!nix-shell` shebang**：`update.sh` 必须使用 `#!/usr/bin/env nix-shell` 加 `#!nix-shell -i bash -p <工具>` 的方式声明依赖工具（如 `nodejs`、`prefetch-npm-deps`），而非先 `nix build nixpkgs#<工具> --print-out-paths` 再引用输出路径
- **示例**：

  ```bash
  #!/usr/bin/env nix-shell
  #!nix-shell -i bash -p bash -p nodejs -p prefetch-npm-deps
  # shellcheck shell=bash
  SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
  TMPDIR=$(mktemp -d)
  trap 'rm -rf "$TMPDIR"' EXIT
  SRC=$(nix eval --raw .#easycli.src)
  cp -r "$SRC" "$TMPDIR/source"
  chmod -R +w "$TMPDIR/source"
  cd "$TMPDIR/source" || exit 1
  npm install --package-lock-only --ignore-scripts
  cp package-lock.json "$SCRIPT_DIR/package-lock.json"
  NEW_HASH=$(prefetch-npm-deps "$SCRIPT_DIR/package-lock.json")
  sed -i "s|npmDepsHash = \"sha256-[^"]*\";|npmDepsHash = \"$NEW_HASH\";|" "$SCRIPT_DIR/default.nix"
  ```
