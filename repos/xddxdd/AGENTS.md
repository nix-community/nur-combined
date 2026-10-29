# NUR 包创建规则

## 工作流程

- **持续更新文档**：每次根据用户建议修改包后，应将可推广的经验教训更新到本文档（AGENTS.md）中
- **提炼通用规则**：关注用户指出的模式、最佳实践和常见错误，将其转化为可应用于其他包的通用规则

## 提交信息格式

- 本仓库的提交信息格式为 `包名: 描述`，例如 `qemu: add QEMU with qemu-vmvga and nvkvm-pv overlays`、`ik-llama-cpp: add`、`AGENTS.md: document …`
- 一次改动涉及多个包时用逗号列出，例如 `ncmm, uni-api: fix package updates after upstream changes`
- 自动化提交用 `auto: update packages`；整仓库性修复可用描述性标题，如 `Fix package evaluation errors`
- 描述用简短的陈述/祈使句，不加结尾句号
- **AGENTS.md 的增补并入对应包的提交**：随包变更更新的经验教训直接写进该包的 commit（描述仍以包名为前缀），不要单独开 `AGENTS.md: …` 提交，避免文档与代码在历史上脱节

## Nix 包定义规范

### 代码风格

- 除非明确要求，否则不要在创建的 Nix 定义中添加任何注释

### 最佳实践

- **CUDA 构建元数据必须跟随所选工具链**：CUDA 主版本应从所选 `cudaPackages.cuda_nvcc.version` 用 `lib.versions.major` 派生，不要硬编码。
- **固件中的 ELF 也是不透明数据**：固件包应关闭 `dontPatchELF` 对应的修补和 strip（设置 `dontPatchELF = true; dontStrip = true;`），避免签名或摘要失效；在安装检查中对最终产物重新校验上游固定的哈希，不能只校验生成步骤的临时文件。
- **大型 CUDA fatbinary 可导致 x86_64 主机链接重定位溢出**：把多架构 CUDA 与主机代码链接进同一共享库时，超过 2 GiB 的 `.nv_fatbin` 可能被默认链接脚本放在主机代码与数据之间，触发 `R_X86_64_REX_GOTPCRELX` 或 PLT 的 PC-relative offset overflow。可用附加链接脚本将该节 `INSERT AFTER .bss`，仅在 CUDA 变体传入共享库链接参数；不要以减少支持的 GPU 架构掩盖问题。用完整构建和已安装 ELF 的节地址验证布局，再运行实际 CLI。参考 `pkgs/uncategorized/ik-llama-cpp/cuda-fatbin.ld`。
- **上游源码为 CRLF 行尾时先转 LF 再打补丁**：上游仓库的文本文件可能带 CRLF 行尾（如 FlashBrowser 的 index.js），直接对原文件生成的补丁会整文件重写（diff 把每行都视为修改）。正确做法：补丁一律以 LF 内容生成，并在派生的 `prePatch` 中用 `sed -i 's/\r$//' <文件>` 把上游源码转为 LF——转换必须放在 `prePatch`，因为 patchPhase 在 prePatch 之后、postPatch 之前执行。本仓库内所有文件（补丁、脚本等）一律保持 LF 行尾
- **预臭氧（pre-ozone）Electron（< 12）在 Wayland 会话下必须强制 GDK_BACKEND=x11**：nixpkgs 的 gtk3 含 Wayland 后端，`WAYLAND_DISPLAY` 存在时 GTK 优先走 Wayland，旧版 Electron（Chromium 无 ozone）初始化显示失败报 `Gtk-WARNING **: cannot open display`。在包装器的 makeWrapper 里加 `--set GDK_BACKEND x11`（用 `--set` 而非 `--set-default`：用户会话可能全局设了 `GDK_BACKEND=wayland`，而旧 Electron 根本无 Wayland 支持，保留用户值只会失败）。配套注意旧 Electron 的 rpath：新版 Electron 把大部分 X 库静态打包进二进制，旧版（如 Electron 9）动态链接 `libXcursor`/`libXi`/`libXrender`/`libXtst`，且新版 nixpkgs 已把 `libgbm` 从 `mesa` 拆出为独立包，`electronLibPath` 需按版本条件补齐，否则报 `error while loading shared libraries`
- **打包 llama.cpp 旧布局 fork（如 ik-llama-cpp）时的指令集与版本检查限制**：llama.cpp 的运行时调度机制（`GGML_CPU_ALL_VARIANTS` + `GGML_BACKEND_DL`，靠 `ggml/src/ggml-cpu/` 下的分拆实现）在 fork 点之前或被上游删去时不可用，分支的 `ggml.c` 中 SIMD 路径全是编译期 `#if defined(__AVX2__)` 门控，单个 `add_library(ggml)` 只能选一套 `-m` 标志——只能暴露 `avxSupport/avx2Support/avx512Support` 等布尔参数按 ISA 出多个变体。注意 GCC 的 `-mavx2` **不**隐含 `-mfma`/`-mf16c`（实测 `gcc -mavx2 -dM` 无 `__FMA__`/`__F16C__`），而 IQK 热路径在 `defined(__AVX2__) && defined(__FMA__)` 上分支，所以 avx2/avx512 变体必须同时打开 GGML_FMA/GGML_F16C。另外 GCC 16 新增的 `-Wtemplate-body` 诊断会把分支内上游 IQK FA 模板（`iqk/fa/iqk_fa_templates.h`）里的 `__m512`→`__m256` 隐式转换变成硬错误，avx512 变体在 GCC 16 下无法构建，只能等上游修复后重加。此类 fork 的构建信息从 `.git` 读取，fetchFromGitHub tarball 打出的二进制只会打印 `version: 0 (unknown)`，versionCheckHook 无法比对版本，只能去掉
布尔型选项用 `lib.cmakeBool "OPTION" true|false`（产出 `-DOPTION:BOOL=TRUE/FALSE`），字符串/路径型选项用 `lib.cmakeFeature "OPTION" "value"`（产出 `-DOPTION:STRING=value`），不用 `-DX=ON/OFF` 字面量；生成器开关（如 `-GNinja`）与设为空字符串的特例（如 `-DCMAKE_OSX_ARCHITECTURES=""` 可用 `cmakeFeature` 传空串）除外
- **优先使用 finalAttrs 而非 rec**：新包一律写成 `stdenv.mkDerivation (finalAttrs: { ... })`（或 `buildPythonPackage (finalAttrs: { ... })` 等 mkDerivation 风格构建器的等价形式），不用 `rec`；包内自引用统一用 `finalAttrs.<attr>`。src 的 URL/tag 中出现版本号字面量时改用 `${finalAttrs.version}` 插值——nix-update 只对 `version = "..."` 行做文本替换，插值 URL 会随 version 属性自动更新。注意：`writeShellApplication`、`appimageTools.wrapType2/extract` 等不接受 functor 参数的构建器不能这样转换；纯 `.overrideAttrs` 包装文件与 sources.json 多源包无版本字面量可引用，保持原样
- **保持二进制文件名与源码一致**：安装二进制文件时，使用与源码中相同的文件名，不要重命名
- **使用 versionCheckHook**：在可能的情况下，为包添加 `versionCheckHook` 以验证版本一致性。需要添加以下配置：
  - 在 `nativeInstallCheckInputs` 中添加 `versionCheckHook`
  - 设置 `doInstallCheck = true`
  - 如果程序需要特定参数来显示版本，设置 `versionCheckProgramArg`（如 `--version`）
- **版本/安装检查仅针对产出可执行文件的包**：`versionCheckHook`/`installCheckPhase` 一类检查只在包产出可执行文件时才有意义；纯内核模块包（如 `pkgs/kernel-modules/gpu-unlock`）不产出可执行文件，不要为 `modinfo`/版本验证添加 `doInstallCheck` 和 `installCheckPhase`（曾因 `.ko.cer` 与 `.ko.xz` 同树共存触发 `find -name '*.ko*'` 双匹配而失败，直接移除）
- **内核模块包必须通过 kbuild `modules_install` 安装**：nixpkgs 内核用 kmodigest 覆盖 `cmd_sign`（见 `pkgs/os-specific/linux/kernel/common-flags.nix`），模块签名发生在 `scripts/Makefile.modinst`（`modules_install` 阶段）：安装、`kmodigest` 签名并在模块旁生成确定性单模块证书 `<name>.ko.cer`、按 `CONFIG_MODULE_COMPRESS` 压缩。手动 `install` `.ko` 会同时丢掉签名与 `.cer`，使下游 `aggregateModules` 合并证书时报 `cat: ...ko.cer: No such file or directory`（nixpkgs #575192/#576651 实例）。所以：(1) 能用 `env.KSRC` + `preBuild`/`makeFlagsArray+=` 加 `-C KOBJ M=$(pwd)` 时优先走 `installTargets = [ "modules_install" ]` + `env.INSTALL_MOD_PATH`，或仿 nixpkgs broadcom_sta 用 `installFlags = [ "-C" KBO "M=$(PWD)" ]` 绕过上游无此 target 的 Makefile（xt_rtpengine 实例）；(2) 不要在 installPhase 里手写 kmodigest/安装/xz 复刻 modinst 行为；(3) QDMA 这类多变体共用一个构建目录的驱动，kbuild 每次运行会重写 `modules.order` 只剩最后一个变体，需在 `preInstall` 把全部 `<name>.o` 补回 `modules.order` 再行 `modules_install`（qdma 实例）；(4) 验证产物：`lib/modules/<ver>/.../<name>.ko.xz` 与同目录 `<name>.ko.cer`，`xz -dc` 解压后 `tail -c 60` 应含 `~Module signature appended~`，证书 `openssl x509 -inform DER -noout -subject` 应为 `CN=<name>.ko`
- **不要禁用测试**：`doCheck` 默认启用，不需要设置 `doCheck = false`。仅当上游测试在 Nix 构建环境中确实无法通过时（如需要网络访问、需要特定硬件等），才应禁用测试
- **禁用测试时启用安装检查**：如果设置 `doCheck = false` 禁用测试，必须同时设置 `doInstallCheck = true` 以确保 `versionCheckHook` 正常工作
- **上游版本不一致处理**：当上游 Cargo.toml / package.json 等文件中的版本号与发布标签不一致时，可在 `postPatch` 中使用 `sed` 正则动态修正版本号，以使 `versionCheckHook` 正常工作
- **回移安全补丁时保留未修复的漏洞元数据**：补丁应追加到实际编译源码的派生（包装包通常是 `unwrapped`），保留原有补丁和 `meta`；只按已修复 CVE 的精确前缀过滤 `knownVulnerabilities`，不要清空整个列表。
- **处理 execstack 标记**：打包上游二进制时如遇到 `cannot enable executable stack`，用 `execstack -c`（`pax-utils`）或 `patchelf --clear-execstack` 清理需要可执行栈的 ELF（常见于某些 `.so`）
- **.NET 单文件（PublishSingleFile）自包含预编译二进制**：上游以 `dotnet publish -p:PublishSingleFile=true` 产出的自包含 ELF（如 Cleanuparr）把 .NET 运行时与托管程序集作为**裸数据追加在 ELF 段之后**（文件可达数百 MB）。打包时有三个坑：(1) 默认 `stripPhase` 会把追加在 ELF 之后的 bundle 当作非 ELF 数据截掉，把几百 MB 的可执行文件削成十几 MB 的废桩，必须设 `dontStrip = true`（`buildDotnetModule` 已默认设）；(2) `autoPatchelfHook` / `patchelf --set-rpath` 会重写 ELF section 布局，破坏追加 bundle 的偏移，运行时报 `Failure processing application bundle; possible file corruption. Arithmetic overflow while reading bundle.`，因此**不能使用 autoPatchelfHook**，只能用 `patchelf --set-interpreter` 单独改解释器（该操作不挪动 section，不破坏 bundle），运行时库改用 `makeWrapper --prefix LD_LIBRARY_PATH` 注入；(3) 运行时依赖通常需要 `stdenv.cc.cc.lib`（libstdc++）、`icu`（缺失时报 `Couldn't find a valid ICU package installed on the system`）、`openssl`（缺失时报 `No usable version of libssl was found` 并 core dump）。此外这类应用常把配置/日志目录默认放在 `AppContext.BaseDirectory`（即只读 store 里的 exe 旁），需在 wrapper 里通过上游提供的环境变量重定向到可写位置（如 Cleanuparr 的 `CLEANUPARR_CONFIG_PATH`，用 `makeWrapper --run 'export XXX="''${XXX:-''${XDG_CONFIG_HOME:-$HOME/.config}/pkg}"'` 设默认值，保留用户覆盖能力）
- **从源码构建 .NET 项目（buildDotnetModule）**：优先用 nixpkgs `buildDotnetModule` 从源码构建而非打预编译二进制。.NET 10 用 `dotnet-sdk = dotnetCorePackages.sdk_10_0`、`dotnet-runtime = dotnetCorePackages.runtime_10_0`；自包含单文件设 `selfContainedBuild = true` + `dotnetFlags = [ "-p:PublishSingleFile=true" ]`。NuGet 依赖锁文件用 `passthru.fetch-deps` 生成：派生里写 `nugetDeps = ./nuget-deps.json;`（先放占位 `[]`），构建后**直接执行生成的脚本文件**（`/nix/store/...-<pkg>-fetch-deps`），不要用 `nix run .#<pkg>.fetch-deps`——后者按 `meta.mainProgram` 找 `bin/<mainProgram>`，而 writeShellScript 产物是单文件无 `bin/` 目录，会报 `Not a directory`；脚本默认 depsFile 可能解析成只读 store 副本，需显式传工作区文件路径作第一个参数：`/nix/store/...-fetch-deps "$(pwd)/nuget-deps.json"`。**上游私有 NuGet 包（仅发布到 GitHub Packages 需认证）的处理**：先确认其源码是否公开（常有公开 fork 仓库），若公开则在 `postPatch` 里把 fork 源码拷进源码树，用 `substituteInPlace` 把 `<PackageReference Include="X" Version="Y" />` 替换成 `<ProjectReference Include="../path/to/fork.csproj" />`，这样 restore/build 完全走公开 NuGet，无需认证、无需为每个私有包单独 `packNupkg`+生成 deps；记得把 fork csproj 里的 `<GeneratePackageOnBuild>true</GeneratePackageOnBuild>` 改成 false 避免构建期打包。`buildDotnetModule` 的 `projectReferences`（配合 `packNupkg=true`）是另一条路但要求 nupkg 版本与 `PackageReference` 完全一致、且每个 nupkg 都要单独跑 fetch-deps，比 ProjectReference 替换法繁琐。**makeWrapperArgs 注意**：dotnet-hook 在非 structuredAttrs 时用 `makeWrapperArgs=( ${makeWrapperArgs-} )` 做不安全词分割，会把含空格的 `--run 'export ...'` 拆成多个参数报 `makeWrapper doesn't understand the arg`，需设 `__structuredAttrs = true` 保留数组；makeWrapperArgs 里的 `$out` 不会被运行时展开（makeWrapper 把它当字面量嵌入），要引用输出路径必须用 `${placeholder "out"}` 让 Nix 在求值期替换。**executables 必须显式指定**：否则 hook 的 `find $installPath ! -name "*.dll" -executable -type f` 会把随附的 `libe_sqlite3.so`/`libMono.Unix.so` 等带可执行位的 .so 也包进 `bin/`；设 `executables = [ "<AssemblyName>" ]` 只包主程序，wrapper 名取 exe basename（大小写敏感），可用 `postFixup = ''ln -s <ExeName> $out/bin/<lowercase>''` 提供 `meta.mainProgram` 对应的小写命令。前端（Angular/npm）单独用 `buildNpmPackage` 构建（`nodejs = nodejs_26`，`npmDepsHash` 用 `prefetch-npm-deps package-lock.json` 算），在 `postPatch` 把其 `wwwroot` 拷到主项目的 `wwwroot/` 目录，使 `dotnet publish` 把静态文件作为 static web assets 一并产出
- **预编译 npm 包（buildNpmPackage + dontNpmBuild）的三个坑**：(1) 依赖树中有自带 `npm-shrinkwrap.json` 的包（如 `@earendil-works/pi-coding-agent`）时，npm 会在父 lockfile 中为 shrinkwrap 子树记录**无 integrity 的嵌套条目**，Rust 版 `prefetch-npm-deps` 解析时直接 panic（`non-git dependencies should have associated integrity`）。修复：lockfile 生成脚本里用 Python 下载各条目的 `resolved` URL 计算并注入 `sha512-` integrity（无 `resolved` 的 `inBundle` dev 条目可跳过，prefetch 能容忍）。(2) 生成 lockfile 必须用真实 `npm install --ignore-scripts`（含 `--package-lock-only` 会漏掉部分平台 optional 依赖，如 `@img/sharp-win32-x64`，导致 `npm ci` 报 `Missing: ... from lock file`）。(3) npm 的 make-fetch-happen 在按 URL 查缓存时（用于**无 integrity** 的 fetch，如 shrinkwrap 子树）会调用 `cacache.index.compact()` 往缓存写临时文件，而 npmDeps 缓存挂载在只读 store 上（`mkdir .../tmp` 失败 → `ENOTCACHED`；带 integrity 的 fetch 走 byDigest 纯读路径不受影响）。修复：设 `makeCacheWritable = true`（npmConfigHook 会把缓存复制到可写目录，代价是每次构建多拷几百 MB）。`prefetch-npm-deps` 缓存布局为 `<npmDeps>/_cacache/{index-v5,content-v2/sha512}`，与 npm 的 `flatOptions.cache = <cache>/_cacache` 一致，无需额外处理。**上游仓库 lockfile 不可直接复用**（如 pi-web）：npm registry tarball 不含 lockfile，上游 GitHub 仓库虽提交了 `package-lock.json`，但它是 bun（`bun.lock` 为主锁）环境下的次要产物——既有无 integrity 的 shrinkwrap 嵌套条目（仍需 Python 注入），又混入 bun 转换残留包（`confbox`/`mlly`/`pathe`/`pkg-types`/`ufo`）并缺少新版平台 optional 依赖（如 `@unrs/resolver-binding-linux-loong64-gnu`），一旦与 `package.json` 失步 `npm ci` 直接报错；应从发布 tarball 的 `package.json` 用真实 `npm install` 自行生成。**生成式 lockfile 包的更新脚本整合**（如 pi-web）：不要再同时挂 `nix-update-script` passthru 与 `update-standalone.sh` 双机制——顶层 `update` 命令先跑 `update-standalone.*` 后跑 `update-package --all`，lockfile 会按旧版本重生成、随后 nix-update 只改版本号留下失步的 `npmDepsHash`。正确做法是单一 `update.sh`（`passthru.updateScript = [ (toString ./update.sh) ];`）：先 `nix-update "$UPDATE_NIX_ATTR_PATH" --version "$(npm view <pkg> version)" --src-only` 更新版本与 src 哈希（`--src-only` 跳过 npmDepsHash，否则 nix-update 会对旧 lockfile 跑 `npm ci` 失败中止），再从新 src 重生成 lockfile、注入 integrity、用 `prefetch-npm-deps` 回写 `npmDepsHash`
- **Node.js 运行时程序一律用 makeWrapper 包一层并设 `NODE_ENV=production`**：凡最终程序由 node 解释 JS 入口文件启动的包（buildNpmPackage 安装的 CLI/服务端），都应在 `$out/bin` 里以 `makeWrapper ${lib.getExe nodejs} ... --set NODE_ENV production` 包一层，让 React/Next/Express 等走生产分支而不是开发分支。(1) 已有自定义 `postInstall` 包装的包（如 browser-control-mcp/epub-to-xtc-converter/metapi/n8n-openai-bridge/vuetorrent-backend/waline），直接在 makeWrapper 参数里加 `--set NODE_ENV production`。(2) 没有自定义包装、只依赖 `buildNpmPackage` 自动生成 bin wrapper 的包（如 pi-web：nixpkgs 的 `nodejsInstallExecutables` hook 会用 `makeWrapper @hostNode@ "$out/bin/<bin>" --add-flags ...` 自动包装 package.json 的 `bin`），用派生属性 `makeWrapperArgs = [ "--set" "NODE_ENV" "production" ]`，hook 会把该数组透传给 makeWrapper。（注意：如果包既有自动 bin wrapper 又在 postInstall 里手动 makeWrapper 同一个名字，后者会覆盖前者，务必把 NODE_ENV 加在手动那一层。）(3) `buildNpmPackage` 配合 `npm prune --omit=dev` 在锁文件含 `npm-shrinkwrap.json` 子树（如 `@earendil-works/pi-coding-agent`）时会触发 arborist bug：`reify.js` 的 `_rollbackMoveBackRetiredUnchanged` 中 `realFolders.get(retireFolder)` 返回 undefined，报 `ERR_INVALID_ARG_TYPE: The "from" argument must be of type string. Received undefined`（npm 11.19 仍存在；本地手动 prune 不复现，因为构建目录里有 package-lock.json，去掉锁文件或在 `$out` 包目录里 prune 都能成功）。修复：设 `npmFlags = [ "--omit=dev" ]`（安装期就不装 dev 依赖）加 `dontNpmPrune = true`（跳过有 bug 的 prune 步骤），两者缺一不可——只加 `--omit=dev` 仍在 prune 处失败，只加 `dontNpmPrune` 会把 dev 依赖留在产物里。
- **使用顶层 Xorg 包**：Xorg 相关的库和工具现在可以直接作为顶层包引用，不要使用 `xorg.` 前缀。例如使用 `libX11` 而不是 `xorg.libX11`，使用 `xcbutilimage` 而不是 `xorg.xcbutilimage`
- **不要使用已弃用的 `system` 属性**：在 NixOS 26.05+ 中，`pkgs.system` 已被弃用，访问时会触发 `evaluation warning: 'system' has been renamed to/replaced by 'stdenv.hostPlatform.system'`。获取当前系统平台时应使用 `stdenv.hostPlatform.system`（或 `final.stdenv.hostPlatform.system`、`prev.stdenv.hostPlatform.system`）。特别注意 `callPackage` 会从 pkgs 作用域自动注入参数，因此辅助函数若声明了 `{ system, ... }` 参数，实际会访问到已弃用的 `pkgs.system`，应改为声明 `{ stdenv, ... }` 并在函数内部用 `let system = stdenv.hostPlatform.system; in` 派生
- **扁平打包的二进制压缩包**：当上游 tarball 不包含单一顶层目录（直接在 `./` 下展开文件）时，stdenv 默认 `unpackPhase` 会报 `unpacker produced multiple directories`。此时需设置 `sourceRoot = "."`，让构建在解压根目录进行。但要注意：设置 **`sourceRoot = "."` 后源码根目录就是 `$NIX_BUILD_TOP`，stdenv 每个 phase 开始时的 `dumpVars()` 调试文件 `env-vars`（内含 `NIX_CC`/完整 `PATH` 等）会落在源码根目录，被 `cp -r *` 一并拷进产物，把 `stdenv.cc` 拉进运行时闭包——对设置了 `disallowedRequisites = [ stdenv.cc ]` 的下游包装（如 nixpkgs `wrapFirefox`）会直接报 `output ... is not allowed to refer to gcc-wrapper`。修复：在包里设置 `noDumpEnvVars = true;`（官方 stdenv 开关），而不是在 installPhase 里删文件。实测于 `invisible-firefox-bin`（源码见上文 firefox_antidetect_patch 条目）
- **上游源码归档不再包含可构建源码时**：若 release 仍提供按平台构建的二进制归档，不要继续对缺失源码的 GitHub source tarball 使用语言构建器（例如 `buildGoModule`）；改用 `fetchurl` 获取 release asset，按 `stdenv.hostPlatform.system` 选择对应文件和哈希，并在 `meta.platforms` 中明确列出支持的平台。若所有平台共用同一内容哈希，可通过标准 `nix-update-script` 更新；若每个平台的 release asset 内容和哈希不同，则需用自定义 `update.sh` 更新版本并逐个平台重算哈希，避免只更新 CI 当前平台的哈希。
- **structuredAttrs 下修改 patches 列表**：当 `structuredAttrs is enabled` 时，不能在 `prePatch` 中通过修改 `patches` 变量来过滤补丁（`concatTo` 无法正确解析被修改后的字符串变量）。应改为完全覆盖 `patchPhase`，在其中用 `concatTo patchesArray patches` 读取补丁列表后自行过滤和应用。
- **setuptools 82+ 移除了 `pkg_resources`**：老版本的 XStatic 等包在 `xstatic/__init__.py` 和 `xstatic/pkg/__init__.py` 中使用 `__import__('pkg_resources').declare_namespace(__name__)`，在 setuptools 82+ 中会报 `ModuleNotFoundError: No module named 'pkg_resources'`。修复方法：在 `postPatch` 中用 `substituteInPlace` 删除该调用，同时用 `sed` 从 `setup.py` 中删除 `namespace_packages` 行。
- **PyPI URL 必须带文件扩展名**：PyPI 的 `pypi.io/packages/source/<首字母>/<名>/<名>-<版本>` 路由已不再服务不带扩展名的 URL（返回 404，报 `cannot download ... from any mirror`），`mirror://pypi/...` 的 fetchurl URL 必须写成完整文件名（如 `<名>-<版本>.tar.gz`）。另外 PyPI 可能用归一化名称重新上传 sdist（如 `XStatic-Font-Awesome` 的 sdist 改名为 `xstatic_font_awesome-6.2.1.2.tar.gz`），此时需同步改 URL 并更新哈希；重新生成的 sdist 往往改用现代 setuptools（`find_namespace_packages`、无 `pkg_resources`），原有的 pkg_resources 相关 `postPatch` 补丁应一并删除。
- **pythonMetadataCheckPhase 与 pname 不一致**：新版 nixpkgs 的 `pythonMetadataCheckPhase` 钩子会用 `importlib.metadata.version($pname)` 校验已安装包元数据，要求派生 `pname` 与上游 PyPI 分发名（PEP 503 归一化）一致且版本合法相等。若派生 `pname` 与 PyPI 名不一致导致检查失败，把 `pname` 改为真实分发名；仅当 `version` 无法对齐时才用 `dontCheckPythonMetadata = true;` 关闭检查。注意：钩子对含 `unstable-` 的版本串会整体跳过 PEP 440 校验与版本相等比较（`python-metadata-check-hook-compare.py`），因此 git 快照版本无法对齐时只需改 pname、无需关检查（cockpy 内嵌 pyenet 实例：pname `cockpy-pyenet` → `enet`）。
- **nixpkgs 依赖被 setuptools 上界约束打破**：当 nixpkgs 的某个 Python 依赖（如 `mfusepy`）在 `[build-system] requires` 中钉死 `setuptools < 83`，而 nixpkgs 已升级到 setuptools 83，构建期会报 `Unmet dependencies`。应在直接引用该依赖的包内就地覆盖，而不要在 `pkgs/python-packages/default.nix` 的 `self` 集合中全局覆盖：在该包定义里用 `let <pkg>' = <pkg>.overridePythonAttrs (old: { postPatch = (old.postPatch or "") + ''\n        substituteInPlace pyproject.toml --replace-fail 'setuptools >= 61, < 83' 'setuptools >= 61'\n      ''; }); in` 得到放宽约束的版本，并在依赖列表中使用 `<pkg>'`（务必拼接原有 `postPatch`，避免丢失既有补丁）。
- **cargoRoot + buildAndTestSubdir 处理子目录 Cargo 工作区**：当仓库根目录下只有某个子目录含 Cargo.toml（如 uni-api 的 `rust/uni-api-native`），且源码树其它位置有文件被子目录里的 `include_str!`/`include_bytes!` 引用（相对路径会向上逃出子目录）时，不能用 `sourceRoot` 指向子目录——那会把仓库其余部分裁掉导致编译报找不到文件。正确做法：不设 `sourceRoot`，用 `cargoRoot = "rust/uni-api-native"`（让 cargo-setup-hook 在子目录找 Cargo.lock 与 vendor）加 `buildAndTestSubdir = "rust/uni-api-native"`（让 cargoBuildHook/cargo test 在子目录执行，CARGO_TARGET_DIR 仍在源码根），仓库根的文件保持可见。
- **rustc 1.98.1 在环状 glob 重导出上无限递归**：nixpkgs 锁定的 rustc 1.98.1 尚未包含 rust-lang/rust#160983 的修复，crate 中若出现 `mod restore; pub(crate) use restore::*;` 且子模块里有 `use super::*;`，`rustc_resolve::effective_visibilities` 的 `update_decl_chain` 会沿 `ambiguity_vis_max` 的环无限自我递归，报 `rustc unexpectedly overflowed its stack`（`RUST_MIN_STACK`/`ulimit -s` 调多大都没用，因为是死循环，不是栈不够）。修法：用补丁把该 glob 重导出拆成显式 `pub(crate) use restore::{a, b};`，并把备份模块里直接调用的 `pub(super)` 项（如 `desktop_profile_needs_mapping`）也显式 `use restore::...;`（glob 重导出原本会把可见项带进当前模块作用域，拆开后需补上）；如要保留测试可编译，再加 `#[cfg(test)] pub(crate) use restore::*;`（`doCheck = false` 的包不会编译测试，不触发该 bug）。定位方法：报错栈里的地址用 `nm -C librustc_driver-*.so` 取所在符号确认，再用 `cargo check` 逐个注释 `pub(crate) use <child>::*;` 二分；本地准备好 `.cargo/config.toml` 指向 vendor 目录后，`cargo check` 只需重编最后一个 crate，迭代很快。nixpkgs 升级到含该修复的 rustc 后应删掉此补丁。
- **`prefetch-npm-deps` 哈希对 lockfile 字节（结尾换行）敏感**：生成式 lockfile 的更新脚本若用 Python `json.dump` 重写 `package-lock.json` 会丢掉结尾换行，而 npmDeps FOD 的输出包含 lockfile 本身，导致 `prefetch-npm-deps` 算出的 `npmDepsHash` 与仓库中带换行的 lockfile 不一致（两者仅差结尾 `\n`，哈希也会变）。修复：脚本写文件后补一句写 `\n`（`open('package-lock.json','a').write('\n')`），保证每次重生成的 lockfile 与提交版本字节一致、哈希稳定。
- **cmake 构建钩子进入 build/ 目录后不回退**：nixpkgs 的 `cmakeConfigurePhase` 会 `cd "$cmakeBuildDir"`（默认 `build/`）且之后不会回到源码根目录，因此自定义 `installPhase` 里所有相对路径都基于 build 目录（如 `cp build/strata` 实际是 `build/build/strata` 而失败）。钩子会把 `cmakeDir` 设为 `..`（useCmakeBuildDir 时）或 `.`（dontUseCmakeBuildDir 时），自定义阶段的 installPhase/buildPhase 开头写 `cd "$cmakeDir"` 回到源码根目录即可兼顾两种模式（strata 实例）。
- **GNU patch 默认 backup-if-mismatch，fuzz 应用会留下 .orig 备份**：补丁上下文偏移导致 fuzz 应用（而非干净匹配）时，GNU patch 会在源码树留下 `<file>.orig` 备份，被后续安装逻辑 `cp -a .` 拷进产物；同时补丁文件末尾缺换行会报 `patch unexpectedly ends in middle of line`。重新生成上下文精确匹配、带末尾换行的补丁，两个问题同时消除（`patch --dry-run` 输出无 fuzz 即可）。
- **上游补丁失效时的重新生成方法**：当上游源码结构变化（目录改名、CMakeLists 重构等）导致已有补丁 hunk 失败（`Hunk #N FAILED -- saving rejects`）时，不要手工改补丁上下文，而应在 `/tmp` 解包新源码，把同一套变换（sed/Python）应用到副本上，再用 `diff -u old new` 重新生成补丁（注意把 `--- old/`、`+++ new/` 前缀改回 `a/`、`b/`，并在副本上 `patch --dry-run` 验证）。同时必须检查上游是否新增了带有同类代码模式的文件：旧的 `qt6-qchar-fix.patch` 只覆盖了 `DeveloperComponents/` 下的文件，上游把该目录改名为 `Development` 并新增了多个文件后，同样的 `QChar(ElaIconType::X)` 编译错误出现在 `ElaIcon.cpp`（`QChar(awesome)`）、`ElaKeyBinder.cpp`、`ElaToolButton.cpp`（`QChar(icon)`）、`ElaText.cpp`（`QChar(d->_pElaIcon)`）、`ElaFooterDelegate.cpp`/`ElaNavigationStyle.cpp`（`QChar(node->getAwesome())`）等变量形式中，需一并覆盖（用 `static_cast<char16_t>(...)` 包住）；这些新增文件若未覆盖，patchPhase 过后会在编译期才报 `no matching function for call to 'QChar::QChar(ElaIconType::IconName&)'`。
- **上游 go.mod 要求比 nixpkgs 更新的 Go 补丁版本**：当 go.mod 声明 `go 1.26.6` 而 nixpkgs 默认 `go` 仍为 1.26.5 时，构建报 `go.mod requires go >= 1.26.6 (running go 1.26.5; GOTOOLCHAIN=local)`。修复：直接用版本绑定的 `buildGo127Module`（nixpkgs 为各 Go 主版本提供 `buildGo12XModule`，等价于 `buildGoModule.override { go = go_1_27; }`，比 override 更简洁）作为构建器。仓库锁定的 nixpkgs 中 `go_1_27` 可能是 1.27rc3，仍满足 `>= 1.26.6` 即可用；用 `nix eval --raw .#packages.<system>.<pkg>.go.version` 可确认实际生效的 Go 版本。**切工具链不会让 auto-update 自愈，同一提交必须重算 vendorHash**：goModules FOD 在旧 go 下 `go mod download` 前就报 `go.mod requires go >= X`，stderr 里没有 `got:` 行，nix-update 的 `extract_hash_from_nix_error` 拿不到哈希、抛 UpdateError（helpers/update.nix 单包 FAILED 不中断、照常提交），auto-update 会提交「版本前进了、vendorHash 停在旧时代」的部分更新；切 `.override { go = ... }` 时不重跑 update 流程 vendorHash 就永远不会被修复（cliproxyapi 8.0.39 实例，与 resin 1.3.0 的双重失步叠加）。修复后跑一次 `./tools/update-package <pkg>` 可自动重算三件哈希并用完整 FOD 构建验证。
- **Go 1.27 下 x/net/http2 变为 stdlib shim，会打断 sing-box 的 linkname**（resin 实例，SagerNet/sing-box issue #4450）：Go 1.27 起 x/net/http2 的真实实现在 `//go:build !(go1.27 && !http2legacy)` 门控下被排除、仅余 shim，`(*Transport).connPool` 等内部符号消失，sing-box `transport/v2rayhttp` 里 `//go:linkname` 的拉取报 `relocation target ... not defined`（日志里 go 正常下载完所有模块后才爆，容易误判为依赖问题）。修复：包定标 `tags = [ "http2legacy" ]`（构建标签会被 go 一次传给模块图里的全部包，x/net 会带着旧实现一起编译）；不要为规避此问题降 go 版本或改 go.mod 的 `go` 指令
- **上游 CMake 要求单一 `OPENSSL_ROOT_DIR` 时与 nixpkgs 多输出 openssl 冲突**（gost-engine 3.0.5 实例）：上游 CMakeLists 要求 `OPENSSL_ROOT_DIR` 必须设置，并用 REALPATH 逐一校验 include/libcrypto/libssl 路径不得逃出该根目录——而 nixpkgs openssl 的头文件在 `dev`、库在 `out`，单一 store 路径必然违反校验（`dev` 下找不到 libcrypto，`out` 下找不到 include）。修复：补丁删除 FATAL_ERROR 要求块与逃逸校验 foreach 块（保留 `get_filename_component` 行），并在 cmakeFlags 显式钉死三处路径：`OPENSSL_ROOT_DIR = "${lib.getDev openssl}"`、`OPENSSL_CRYPTO_LIBRARY/OPENSSL_SSL_LIBRARY = "${lib.getLib openssl}/lib/lib{crypto,ssl}.so"`。注意 `lib.cmakeFeature` 断言值是字符串，`lib.getDev` 返回派生必须 `${...}` 插值；不能靠 cmake hook 注入的 NIX_CFLAGS/L 搜索——那只含 `dev` 输出，`out` 找不到，改用「拷贝合并成单一目录」会丢 RUNPATH 导致运行期依赖 LD_LIBRARY_PATH，不要用
- **将应用复制到可写目录的包装器必须保留用户状态**：首次启动前创建目标目录及其父目录；升级时不要 `rm -rf` 整个应用目录，否则配置、启动脚本及模型等用户文件会一并删除。以完整 store 路径而非上游版本号作为刷新标记，使同版本的打包修复也能生效；仅刷新应用文件，保留运行时数据，覆盖用户修改过的应用文件前做备份，并锁定刷新过程避免多个入口并发复制。Strata 的实现与回归测试位于 `pkgs/uncategorized/strata/hydrate.py` 和 `test-hydrate.py`，安装检查运行这些测试。
- **只读 store 源码经 `file(COPY)`/`cp -a` 拷入产物前保留 555/444 权限位，删除拷贝前先 `chmod -R u+w`**（strata 0.2.x 实例）：nix FOD store 路径全是只读（目录 555、文件 444），上游 cmake 用 `file(COPY)`（默认保留权限位）把 llama.cpp 源里的 `vendors/`（cuda.h/hip.h/musa.h）拷进构建树，`cp -a` 入 `share/` 时把 555 权限一并带入；installPhase 里 `rm -rf` 该目录因父目录无写权限而挂（unlink 只看父目录写权限，文件本身 444 不影响，GNU rm 不会自动 chmod）。在 delete 前 `chmod -R u+w` 整棵拷贝树即可；只 chmod 已知的 vendor 子目录更窄但上游新增一次 `file(COPY)` 就会静默复发
- **运行时依赖修复不要触发无关的原生重编译**：Python 运行时依赖与耗时的 CUDA 等原生构建应分开打包；可保留原派生，通过轻量包装补充运行环境，并在包装构建中执行真实依赖检查。修改前后比较原生派生的 `drvPath`，确认仍能复用已有缓存，而不只比较版本号。
- **用 Nix Python 环境替代上游 pip 安装时必须处理环境标记**：检查已安装分发名不够，`requirements.txt` 中可能含 `colorama==...; sys_platform == "win32"` 这类当前平台不适用的依赖；若直接将它们交给 pip，Nix Python 环境没有 pip 时仍会失败。用 `packaging.requirements.Requirement` 解析并评估 marker，跳过不适用的需求；测试必须进入实际安装/启动路径，而不只运行 `--help`（Strata 实例），并覆盖上游聚合的实际运行时依赖（包括可选界面等额外 requirements 文件），不能只检查基础 requirements。
- **Node.js 服务端应用写入运行时文件到源码目录**：基于 thinkjs 等框架的 Node.js 服务端应用常将运行时缓存/日志写入源码旁的目录（如 thinkjs 的 `RUNTIME_PATH` 默认为 `ROOT_PATH/runtime`，而 `ROOT_PATH` 通常硬编码为 `__dirname`）。在 Nix 中源码位于只读 store，会导致写入失败崩溃。修复方法：用补丁修改入口文件，将运行时路径改为从环境变量读取，默认指向可写位置（如 `process.env.XXX_RUNTIME_PATH || path.join(require('node:os').tmpdir(), 'xxx')`），保持 `ROOT_PATH`/`APP_PATH` 指向 store 以加载源码。优先使用独立补丁文件（`patches = [ ./xxx.patch ]`）而非 `substituteInPlace` 内联替换，便于审阅与维护。
- **为修改版 Firefox 关闭 PGO**：`buildMozillaMach` 默认在 x86_64-linux 上启用 PGO（`enablePGO` 默认在 Linux 且非交叉编译且 64 位时为 true；旧版 nixpkgs 中该参数名为 `pgoSupport`，现已被重命名为 `enablePGO`，`ltoSupport` 同样改名为 `enableLTO`），其 `profilingPhase` 会用 `./mach python ./build/pgo/profileserver.py` 启动一次 Firefox 采集 profile。但重度补丁版的 Firefox（如 `feder-cr/firefox_antidetect_patch` 的反指纹分支）会破坏内容进程的干净关闭：`Quitter.quit()` 触发的关闭过程中内容进程 hang，被进程监视器 SIGABRT，LLVM profile runtime 来不及 flush，导致 `llvm-profdata merge` 报 `truncated profile data` / `no profile can be merged`，整个 `profilingPhase` 失败（上游只跑 `./mach build`、从不测试 PGO）。修复方法：用 `.override { enablePGO = false; }` 关闭 PGO（LTO 仍由 `enableLTO` 默认开启，保留）。注意 `buildMozillaMach` 的 `enablePGO` 在其内部派生函数的参数里、不在外层 opts 里，因此不能直接写进 `buildMozillaMach { ... }`，而要用派生的 `.override` 传：`((buildMozillaMach { ... }).override { enablePGO = false; }).overrideAttrs (old: { ... })`。nixpkgs 升级若报 `function 'anonymous lambda' called with unexpected argument 'pgoSupport'` 且导致整个 flake 无法求值，就是此参数改名所致。
- **nginx 模块 `--add-module` 路径跟随上游目录结构**：OpenResty/nginx 自定义包的 `--add-module` 必须指向包含 `config` 文件的目录，上游重构目录后需同步更新，否则 configure 阶段报 `error: no .../config was found`。例如 ja4-nginx-module 把 `config` 从 `src/` 移到仓库根目录后，`--add-module=bundle/ja4-nginx-module/src` 需改为 `--add-module=bundle/ja4-nginx-module`（其 `config` 内部用 `$ngx_addon_dir/src/...` 引用源码，不受影响）。上游模块升级后若 configure 报找不到 `config`，先检查模块仓库中 `config` 文件的实际位置。
- **`.override` 后接 `.overrideAttrs` 必须加括号**：Nix 中属性选择 `.` 的优先级高于函数应用。`X.override { a = 1; } .overrideAttrs (...)` 会被解析为 `X.override ( ({a=1;}).overrideAttrs (...) )`，即对字面量 attrset `{a=1;}` 取 `.overrideAttrs`，报 `attribute 'overrideAttrs' missing`。必须写成 `(X.override { a = 1; }).overrideAttrs (...)`，用括号让 `.override` 先完整应用、再对其结果取 `.overrideAttrs`。
- **versionCheckHook 以隔离环境执行二进制，会把运行时文件烤进 $out 或直接失败**：新版 nixpkgs 的 versionCheckHook 通过 `env --ignore-environment --chdir=/ --argv0=...` 执行被检查的二进制——环境变量被完全清空（HOME 不存在）、cwd 是不可写的 `/`。若程序启动时（init/main）会写运行时文件、且用户目录不可用时会回退到"可执行文件所在目录"（便携式设计，如 BaiduPCS-Go 的 `GetConfigDir` 先探测 exe 旁的旧版配置文件），旧版 hook 会把默认配置写进 `$out/bin/` 烤进最终产物，运行期二进制再因"exe 旁存在配置文件"而永远从只读 store 读写配置（报 `config file permission denied`）；新版 hook 则在 versionCheck 阶段直接 EACCES 失败。修复三件套（baidupcs-go 实例）：(1) 补丁移除 exe 目录回退，强制 `$HOME/.config/<pkg>`（HOME 未设时回退 `.`，保证非交互场景仍可运行）；(2) `nativeInstallCheckInputs` 加 `writableTmpDirAsHomeHook`（其 `postHooks` 把 HOME 指到可写的 `$NIX_BUILD_TOP/.home`），并设 `versionCheckKeepEnvironment = "HOME"` 把 HOME 穿透 `env --ignore-environment` 传给被检查程序——只加 hook 不加该变量无效，因为 hook 设置的 HOME 仍会被 env 清掉；(3) `postInstallCheck` 里 `rm -f $out/bin/<运行时文件名>` 兜底。排查方法：构建后 `ls result/bin/` 检查是否混入运行时文件，其内容里的绝对路径字段会暴露写入发生时的环境
- **eBPF CO-RE 对象在 Nix 沙箱中编译的四件套**：eBPF 程序包（如 skyline-speeder）在沙箱内没有 `/sys/kernel/btf/vmlinux`，也没有可运行的内核 BTF。可靠做法：(1) 用 `bpftool btf dump file ${linuxPackages_6_12.kernel.dev}/vmlinux format c` 从 nixpkgs 内核 `dev` 输出里的 `vmlinux` ELF（含 `.BTF` 段）生成 vmlinux.h；注意 nixpkgs 的 attr 名是 `bpftools`（复数，二进制仍叫 `bpftool`），没有 `bpftool` 包。CO-RE 在加载时按目标内核修正字段偏移，选最老受支持版本（如 6.12 LTS）的 BTF 与上游 release 流水线的 reference header 做法一致；编译产物必须含 `.BTF.ext` 段才是 CO-RE 可重定位的。
(2) BPF 目标不能用 nixpkgs 包装的 `clang`：cc-wrapper 会向编译器注入 x86 专用 CFLAGS（如 `-fzero-call-used-regs=used-gpr`），报 `unsupported option ... for target 'bpf'`；改用 `llvmPackages.clang-unwrapped` 的裸 clang。
(3) 裸 clang 不会自动获得 cc-wrapper 注入的 include 路径，需在 `BPF_CFLAGS` 里显式加 `-I${libbpf}/include`。
(4) 若上游 Makefile 同时负责 Rust/BPF，只需传 `BPF_CLANG`/`BPFTOOL`/`VMLINUX_BTF` 等变量调用 `make bpf`，Rust 部分交给 `rustPlatform.buildRustPackage`。
- **Rust 包不要用 `cargoLock.lockFile = "${finalAttrs.src}/Cargo.lock"`，它会产生 IFD**：`importCargoLock` 内部执行 `builtins.fromTOML (builtins.readFile lockFile)`，而 `${finalAttrs.src}` 求值出的是 fetchFromGitHub 派生的 store 路径，求值期需要先构建这个 FOD，即 import-from-derivation。`nix eval --option allow-import-from-derivation false` 会直接报 `cannot build '/nix/store/...-source.drv' during evaluation`（报错栈指向 `cargoDeps` 属性），对 IFD 敏感的求值场景（CI、`nix flake check`）会失败。正确做法是改用 `cargoHash = "sha256-...";`：nixpkgs 25.05+ 走 `fetchCargoVendor`，是纯构建期 FOD，无 IFD；哈希按常规方法用假哈希构建一次、从报错的 `got:` 行取值（skyline-speeder 实例：`cargoHash = "sha256-l9+SQN4P/lSmYtMCDY0vi0akrcj9yVaipkdPQ0r7Kog=";`），并且 nix-update 能在版本升级时自动更新它
- **从源码打包 Godot 游戏**：用 `godot_4_X`（编辑器）加 `godot_4_X.export-templates-bin`（预编译 export templates，已进 binary cache，远轻于 `godot.export-template` 的源码编译）。导出前把模板目录软链到 `$XDG_DATA_HOME/godot/export_templates`——只设 `HOME` 不够，用户 shell 常已设 `XDG_DATA_HOME` 且其优先于 HOME，沙箱里两个都要设：`export HOME=$TMPDIR; export XDG_DATA_HOME="$HOME/.local/share"`；再 `godot4 --headless --export-release "<preset 名>" <输出路径>`（preset 名是 `export_presets.cfg` 的 `name=` 字段，不一定是 `Linux/X11`）。`binary_format/embed_pck=true` 时游戏数据被追加进 ELF 的 `pck` 段，必须设 `dontStrip = true`（strip 报 `allocated section 'pck' not in segment` 并破坏 pck）和 `dontPatchELF = true`（stdenv 的 patchelf setup-hook 在 fixupPhase 跑 `patchelf --shrink-rpath`，而 Godot 的 X11/Vulkan 依赖全是运行期 dlopen、DT_NEEDED 只有 libc，rpath 会被整个删空），最后在 installPhase 手动 `patchelf --set-interpreter ${stdenv.cc.bintools.dynamicLinker} --set-rpath ${lib.makeLibraryPath buildInputs}`。buildInputs 至少含 `vulkan-loader`、X11 系列（`libx11`/`libxcursor`/`libxext`/`libxfixes`/`libxi`/`libxinerama`/`libxkbcommon`/`libxrandr`/`libxrender`）、`libpulseaudio`、`alsa-lib`、`udev`、`fontconfig`。
- **在 nixpkgs 的 QEMU 上叠加 QEMU fork（qemu-vmvga + nvkvm-pv）**：用 `(qemu.override { ... }).overrideAttrs (old: { ... })` 叠加，不动上游构建流程（实例见 `pkgs/lantian-customized/qemu`）。要点：
  - **补丁系列用循环按序应用**：nvkvm-pv 的 `patches/*.patch` 相互依赖且只针对某一精确 QEMU 版本，用 `for p in ${nvkvmSrc}/patches/*.patch; do patch -p1 --batch --forward --no-backup-if-mismatch < "$p"; done` 一次覆盖（bash glob 已按文件名排序），不要在表达式里再维护一份补丁文件名列表；上游增删补丁时无需改表达式。
  - **纯新增源文件直接 cp 进树**：`src/qemu/*.c|h` 拷到 `hw/misc/`，公共头文件拷到 `hw/misc/nvkvm_inc/`，再用 `sed` 把源码里的 `#include "../../src/{common,abi}/*.h"` 改写成 `#include "nvkvm_inc/*.h"`（否则相对路径指向源码树之外的目录）；把 `nvkvm_linux_types.h` 改名为 `linux_types_compat.h`，并把公共头文件里的 `#include <linux/types.h>` 指向它，避免 `-I` 顺序引入系统内核头文件。
  - **isolate stub 必须先构建再嵌入**：nvkvm 运行期要把一个静态 stub ELF 写进 memfd 再 `dlopen`，它由 `src/stub` 用 `make CC="$CC" XXD=xxd READELF=readelf` 现场生成 `nvkvm_stub_bin.h`；把它拷进 `hw/misc/` 并在 configureFlags 里加 `--extra-cflags=-DNVKVM_STUB_EMBEDDED`。两者缺任一个都能**构建成功**，但设备会静默跑在“isolate stub 未嵌入”的降级模式（隔离转发关闭），只有实跑才能发现：`-device virtio-nvgpu-pci,disable-legacy=on` 应打印 `nvkvm: isolate sandbox: namespace` 一类日志（该设备是 modern-only，不带 `disable-legacy=on` 时 QEMU 直接拒绝实例化）。
  - **qemu-vmvga 的 3D 加速要三件事同时成立**：(a) 设备在运行期 `dlopen("libdxvk_d3d9.so.0")`/`libdxvk_d3d11.so.0`，这两个库没有任何 DT_NEEDED 引用它们，linker 因此不会把其目录写进 rpath，需在 `postFixup` 里对 `$out/bin/qemu-system-*` 与 `.qemu-system-*-wrapped` 逐个 `patchelf --add-rpath ${lib.getLib dxvk}/lib`；(b) 设备初始化 DXVK 前会把自己合成的 headless SDL2 装进 loader 的 namespace（伪造 SONAME `libSDL2-2.0.so.0`），一旦发现真 SDL2 已加载就放弃 3D，所以宿主 QEMU 不能自己链接 SDL2（`qemu.override { sdlSupport = false; }`）；(c) nixpkgs 的 dxvk 被 patch 成按**绝对路径** `dlopen` 它依赖的 SDL2，正好绕过 (b) 的伪造 SONAME，必须在 dxvk 派生里把该替换改回裸 soname（`substituteInPlace src/wsi/sdl2/wsi_platform_sdl2.cpp --replace-fail '${lib.getLib SDL2}/lib/libSDL2-2.0.so.0' 'libSDL2-2.0.so.0'`）。三者缺一的症状各不相同：缺 (b)/(c) 是带 `-device vmvga` 启动即 SIGSEGV（gdb 栈顶落在 sdl2-compat/SDL3 的 `SDL_Vulkan_GetInstanceExtensions_REAL`）；缺 (a) 是 `failed to load libdxvk_d3d9.so.0` 后静默退回软件渲染。验证手法：`-device vmvga,debug=on -display none -S` 下 DXVK 日志出现 `Extension providers: Platform WSI` 且启用的实例扩展含 `VK_EXT_headless_surface`（证明用的是设备自带的 headless WSI 而不是真 SDL2），并能枚举到真实 GPU；再由 `-monitor stdio` 发 `quit` 确认退出码为 0（rpath/SDL2 有问题时这一步会 SIGSEGV）。
  - **继承 nixpkgs 的 `meta.platforms` 可能让包直接从 README 里消失**：nixpkgs 给 qemu 设的是新式 platform pattern（`lib.systems.inspect.patternLogicalAnd ...`）而不是字符串列表，而本仓库 README 生成器用 `lib.elem system p.meta.platforms` 判断平台，匹配不上就不列出该包。此类包必须显式覆盖 `meta.platforms`（如 `lib.platforms.linux`）。

- **打包 AMD Vivado（Xilinx 统一安装器）的关键机制**：包位于 `pkgs/uncategorized/vivado/`，未包装树 + buildFHSEnv 包装。要点：
  - **源码提供**：installer tar（`FPGAs_AdaptiveSoCs_Unified_SDI_*.tar`，约 104 GB）无法直接下载，用 `requireFile` 引用，用户本地执行 `nix store add --mode flat <tar>` 注入 store（`nix hash file` 预先算哈希）。
  - **无人值守安装**：先用 `xsetup -b ConfigGen -i CLI` 交互生成 install config，再 `sed "s/^Destination=.*/Destination=$out/; /Modules=/ s/:0/:1/g"` 修改目的地并开启全部 Modules 提交到 `install-config.txt`；安装命令 `bash ./xsetup -a XilinxEULA,3rdPartyEULA -b Install -c install_config.txt`。零设备 Modules 会直接报错退出，全部 `:1` 可绕过。注意安装器会写入 `$HOME` 与 `~/.Xilinx`（设 `HOME=$NIX_BUILD_TOP/vivado-home`）。
  - **安装前必须修 shebang**：安装器源码树的 `*.sh` 全部用 `/bin/bash` 绝对路径，沙箱里 `/bin/bash` 不存在，导致 `ldlibpath.sh` 死亡从而 `java.library.path` 为空（报 `no xv_install in java.library.path`）；用 stdenv 自带的 `patchShebangs xsetup bin scripts installLibs.sh` 重写（可接受裸脚本名与目录等多种参数形式）。
  - **FHS 下的 dlopen 名称搜索**：buildFHSEnv 的 rootfs `/etc/ld.so.cache` 内只含 SONAME 条目，`ncurses5`（ABI5 兼容包）的 `libncurses.so.5` 文件是通往 wide 构建的同目录符号连接，无法匹配 SONAME；Vivado 运行时对 `libtinfo.so.6`/`libncurses.so.5` 等的 `dlopen` 只能靠文件名扫描（LD_LIBRARY_PATH），因此 buildFHSEnv 的 `profile` 里必须预置 `export LD_LIBRARY_PATH=/usr/lib64:/lib64`（Vivado 的 `ldlibpath.sh` 会保留已设值并前加自身目录）。目标系统库还需补 `pixman`、`libpng`、`libjpeg`（Vivado 自带 libcairo 但缺 pixman）。
  - **包装器文件名冲突**：buildFHSEnv 的默认入口名是 `pname`，若其下被包装的可执行文件也叫 `vivado` 会把 FHS runner 覆盖掉，必须给 buildFHSEnv 指定不同的 `executableName`（如 `vivado-fhs`），然后由 `extraInstallCommands` 把各入口符号连接到 `$out/bin`。
  - **安装式派生的文件检查用 installCheckPhase 而非 checkPhase**：stdenv 的 phase 顺序是 checkPhase 在 installPhase **之前**，而 Vivado 这类包的全部产物由安装器生成，checkPhase 时 `$out` 还不存在（`test -f` 静默失败且杀死后续 installPhase）；改用 `doInstallCheck = true` + `installCheckPhase`（stdenv 的 postCheck 等价物，运行在 fixupPhase 之后）。
  - **autoPatchelfHook 的自动运行在 postFixup，安装发生在 installPhase 时来不及**：这类包在 postPatch 里手动调 `autoPatchelf -- <安装器镜像目录>`（安装器拷出的产物是镜像的子集，一次调用全覆盖），并配 `dontAutoPatchelf = true;` 关掉 postFixup 自动运行（省掉对 86GB 产物树的第二次全量遍历）；运行时依赖由 FHS wrapper 满足时，配 `autoPatchelfIgnoreMissingDeps = [ "*" ];` + `autoPatchelfFlags = [ "--ignore-existing" ];` 得到纯解释器补丁（--ignore-existing 避免把 bundle 库解析进 rpath 烤入构建期路径，jetbrains builder 注释里记录了该行为）。另注意 32 位 ELF 会被按架构自动跳过（自写 find+patchelf 循环会盲写 64 位解释器）。
  - **builder 内管道会受 `set -o pipefail` 影响而静默杀死构建**：stdenv setup.sh 顶部 `set -o pipefail`，`x=$(... | grep -v pattern | ...)` 在 grep 无匹配（exit 1）时会让赋值失败并触发 `set -e` 死亡，且无任何报错输出。管道中间步骤必须换成单进程工具（如 awk）或保证恒返回 0。
  - **stdenv fixup 钩子对上游 vendor 树的两个拦截**：audit-tmpdir 钩子会拒绝 rpath 含 `/build/`（build 机器路径，Vivado 自带的 legacy ISE 库 libtcl8.4/libwrapper 的 rpath 只有这一个组件），需在 preFixup 中剔除 `/build/` rpath 组件（必须在 fixupOutputHooks 之前，即 preFixup）；noBrokenSymlinks 钩子会拒绝上游 SDK bundle 自带的悬空符号链接（如 certs → make-ca 才会生成的 CA 目录），用 `find $out -xtype l -delete` 清理。另注意 buildFHSEnv rootfs 的 ld.so.cache 只收录 SONAME 条目。

## nginx 模块包（pkgs/nginx-modules/）

- **自定义明文代理协议必须同时绕过请求和响应的 HTTP 处理**：只修改发出的请求行或在 HTTP 状态解析失败后接受原始数据，不代表响应已经透明传输。明文模式应在状态行和响应头解析之前直接进入原始响应路径；回归测试应覆盖以合法 HTTP 状态行开头的数据、控制响应头、分片与提前 EOF，并同时验证普通 HTTP 代理行为不变。
- **nginx 第三方模块用 mkNginxPlugin 打包，仿照 nixpkgs nginxModules**：自定义 nginx 模块放在 `pkgs/nginx-modules/<模块名>/default.nix`（目录名即包名，由顶层 loadPackages 自动加载），包定义调用 nixpkgs 的 `mkNginxPlugin (finalAttrs: { ... })`，主体只需 `pname`/`version`/`src`（fetchFromGitHub + 可选 `fetchSubmodules = true`）与 `buildInputs`；rev 跟踪包用 `unstableGitUpdater { url = ...; hardcodeZeroVersion = true; }`（版本 `0-unstable-<日期>`），tag 版本包用 mkNginxPlugin 默认的 `nix-update-script`。`lantianCustomized.nginx` 通过函数参数直接引用这些包（Nix 标识符允许连字符，`ja4-nginx-module` 可作为参数名由 callPackage 自动注入）。
- **mkNginxPlugin 模块的 dynamic 标志在 passthru 里**：nixpkgs 部分模块（vts、brotli）声明 `passthru.dynamic = true`，nginx generic 按 `mod.dynamic or false` 决定 STATIC `--add-module` 还是 DYNAMIC。想在静态/动态间切换不能用直接添加顶层 `dynamic` 属性的 `overrideAttrs`（不生效，因为读取的是 passthru）——要用 `pkg.overrideAttrs (_: { passthru = (pkg.passthru or { }) // { dynamic = false; }; })`；`.override` 不行（会被 mkNginxPlugin functor 的严格参数列表拒收）。另外 nixpkgs `nginx` generic 会自动套用 `nix-etag-1.15.4.patch`、`nix-skip-check-logs-path.patch`、`@nixStoreDir@` 替换和 libxml2 include 修正，包装 nginx 时不要重复提供这些补丁/替换，否则重复应用报错。
- **mkNginxPlugin 模块本身是纯源码 FOD**：它 `dontConfigure/dontBuild/dontFixup`，仅把打过补丁的源码拷到 $out；真正的编译发生在传给 nginx 构建时。模块的 `patches`（如 stream-echo 的补丁）在 FOD 的 patchPhase 应用，所以模块包自身也要能独立 `nix build` 成功。模块 meta 会带 `hydraPlatforms = [ ]`，不单独入 Hydra，仅作为依赖被 nginx 构建拉起。

## 内核模块包

- **模仿现有内核模块包结构，不覆盖 buildPhase**：`pkgs/kernel-modules/` 下的包参照 acpi-ec 的写法——`nativeBuildInputs = kernel.moduleBuildDependencies`、`env.KSRC` 指向 `kernel.dev`、`makeFlags = kernel.commonMakeFlags or kernel.makeFlags`、在 `preBuild` 里用 `makeFlagsArray+=("-C" "${...}" "M=$(pwd)")` 追加参数、`installTargets = [ "modules_install" ]`。不要自写 buildPhase；多个目标用 `buildFlags = [ "targetA" "targetB" ]` 传入（当前 stdenv 已移除 `buildTargets` 属性，不再被默认 buildPhase 消费）。
- **含空格的 `XXX=value` 参数不能放 makeFlags，要派生环境属性**：非 structuredAttrs 路径下 makeFlags 会被按空白分词，`makeFlags = [ "CPPFLAGS=-a -b -c" ]` 中 `-b -c` 会变成杂散 make 参数，只有第一个 flag 生效。structuredAttrs 下此类变量（如 CPPFLAGS）必须写成 `env.CPPFLAGS = "-a -b -c";`，顶层属性不会进环境。
- **现代内核 external module 的 `modules_install` 装到 `updates/` 且可能压缩**：Linux 6.18 默认把 `.ko` 压成 `.ko.xz` 放进 `updates/`；需要未压缩 `.ko`（如装到 `extra/` 以匹配参考实现或自定义加载逻辑）时改用自定义 installPhase 手动 `install`（注意这不是覆盖 buildPhase，安装逻辑放在 installPhase 内属常规做法）。
- **Clang 专属诊断开关（`-Wno-error=parentheses-equality` 等）在 GCC 下硬报错**：nixpkgs 默认 GCC 不认识该 option，出现在命令行会直接编译失败；从面向 Clang 的参考构建移植参数时要剔除，只保留 GCC 认识的 `-Wno-error=...`。

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

### structuredAttrs 约定

本仓库所有包统一设置 `__structuredAttrs = true;` 和 `strictDeps = true;`。新增包必须带上这两个属性，并遵守：

- **位置**：放在推导 `pname`/`version`/`src` 身份块之后（有 `src` 放 `src` 之后；`inherit` 形式同理；都没有时放在 override/包裹的属性集开头）。
- **自定义环境变量必须放 `env`**：`__structuredAttrs` 打开后，顶层的非特殊属性只进入 `__json`（仅 builder 能读），不再作为进程环境变量导出——setup.sh 只导出 `env = { ... }` 中的项。需要被构建工具/子进程以 `$VAR` 形式读到的东西（如内核模块的 `KSRC`、`INSTALL_MOD_PATH`、`CPPFLAGS`，Rust 的 `PROTOC`、Go 的 `GOWORK`）必须写成 `env.X = ...`。
- **flags 变量在 structuredAttrs 下是 bash 数组**：`makeFlags` 等以 JSON 数组桥接为 bash 数组，`preBuild` 里不能再写 `makeFlags="$makeFlags ..."` 字符串拼接（拼接后整体变成单个变量赋值、`-C` 被吞进去），应写 `makeFlagsArray+=("-C" "${...}" "M=$(pwd)")`；数组桥接的 list 属性（makeFlags、makeWrapperArgs 等）可直接消费。
- **writeShellApplication / writeTextFile 的属性放 `derivationArgs`**：这两个 builder 的参数签名是strict的，直接传 `__structuredAttrs` 会报 unexpected argument，须写 `derivationArgs.__structuredAttrs = true;`。
- **override 链上挂 flag 用 `.overrideAttrs`，不要塞进 `.override { }`**：参数签名严格的 builder（kernel builder、writeShellApplication 等）会把多余参数直接拒掉。
- **不要写顶层推导属性当环境变量后再在 phase 里以 `$VAR` 读**：该写法只在非 structuredAttrs 下成立；structuredAttrs 下 `$VAR` 为空。
- **构建时执行的工具必须放 `nativeBuildInputs`**：开启 `strictDeps` 后，仅在 `buildInputs` 中声明 Python、PHP/Composer 或 wxWidgets 不会把其解释器、`composer`、`wx-config` 加进构建 PATH。需要目标库时保留 `buildInputs`，同时把提供构建工具的包加入 `nativeBuildInputs`。Qt 的 qmake 模块路径钩子注册在 `envBuildHostHooks`，因此 `.pro` 中要求的 Qt 模块也必须加入 `nativeBuildInputs` 才能被 qmake 发现，不能只声明目标链接依赖；直接链接的模块仍需放 `buildInputs`。
- **基于 symlinkJoin 的包装包必须关掉 `__structuredAttrs`**：nixpkgs 的 symlinkJoin（mpv wrapper 等）用 `passAsFile` 传递 `paths`，structuredAttrs 下该文件内容非预期，`lndir` 不产生任何链接，`postBuild` 对 `$out` 的操作随之失败。对这类包装设 `__structuredAttrs = false;`（`strictDeps = true;` 可保留）后再 override 其他属性。

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

消费多个上游源的包（如 fr24feed、dbip-lite、qemu-user-static、qq）不要把版本/哈希字面量写死在 default.nix 里，而是：

1. 在包目录下维护 `sources.json`，每个条目含 `version`/`url`/`hash`（nginx 的 GitHub 模块条目为 `owner`/`repo`/`rev|tag`/`hash`/可选 `fetchSubmodules`）
2. default.nix 通过 `builtins.fromJSON (builtins.readFile ./sources.json)` 读取并构造 fetcher
3. 包目录下的 `update-standalone.*` 负责探测新版本、用 `nix store prefetch-file --json [--unpack] <url>` 计算哈希（GitHub tarball 用 `--unpack`，其结果与 fetchFromGitHub 哈希一致），最后整体重写 `sources.json`
4. 注意：nix-update 只支持单一 `version`/`src` 属性，且 `helpers/update.nix` 运行器会跳过含 `sources.` 引用的包，因此多源包必须走本模式；`sort -V` 是字典序，纯数字版本比较需按 `.` 分段转整数排序

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
  - **tempHash 残留会让 updater 永久卡死并被 auto-update 反复提交**（openssl-oqs-provider 实例，2026-09-08 起连续 4 天构建失败，源码级机制已核实）：update-source-version 的 sha256 tempHash 是固定字面量 `AzH1rZF...`。第一次 die（同 rev 但 tag 前缀变化 0.10.0 → 0.12.0-rc1，`--rev` 替换 no-op → cmp 判等 → die）发生在"已写入 tempHash、未写入最终哈希"之间，文件从此残留 tempHash 并被 auto-commit 提交；此后**每次重跑都在 temp hash 替换一步 die**——因为文件里的旧哈希恰好等于 tempHash 字面量，sed 替换是 no-op，cmp 判等报 `Failed to replace source hash ... to a temporary hash!`。updater 自身永远无法自愈，且每日只推进 version 日期（version 与 rev/hash 脱节），依赖方（lantianCustomized.nginx 依赖 openssl-oqs-provider）跟着连续 Dependency failed。修复：手工改三行（rev = 上游 HEAD、version = `<tag 去前缀>-unstable-<HEAD 日期>`、hash = `nix store prefetch-file --json --unpack <HEAD tarball>`），并以 `nix build .#<pkg>.src` 验证；该包已改用自定义 update.sh（见下条），不再使用 unstableGitUpdater
  - 仅支持 git 可 clone 的 URL；dpdk-kmods 只能 `git://dpdk.org/dpdk-kmods`（https 路径 cgit 不提供 smart HTTP）
  - 跟踪的 fork 分支可能比默认分支新（如 flaresolverr-alexfozor），首次运行版本回退属正常
  - `helpers/update.nix` 运行器原生支持 unstableGitUpdater 返回的列表形式 updateScript；`nvlax`（同文件多哈希）与 `qsp`（自定义多步 update.sh）不适用，保持原状
- **nix-update 的文件改写行为（源码已验证）**：`replace_version` 先定位 `version = "..."` 声明行；若该行包含旧版本字符串，则**只改写这一行**，其余行一律不动——因此 `url = ".../foo-1.2.3.tar.gz"` 这种内嵌版本字面量的 URL 永远不会被 nix-update 更新（版本号变了但 src 仍拉旧版，哈希不变，静默失败）。若 version 声明行不含旧版本字面量（如 `inherit version;`），则退化为全文件范围内把带引号的独立字符串 `"旧版本"` 整体替换成 `"新版本"`（仍只匹配独立带引号字符串，匹配不到 URL 内嵌片段）。rev/tag 则不同：nix-update 用求值出的旧 rev/tag 值在全文件做子串替换（release 模式与 `--version branch` 模式都携带新 rev/tag）。综上：**fetchurl 的 URL 必须用 `${finalAttrs.version}` 插值**；fetchFromGitHub 的 tag 也建议插值；rev 字面量可由 nix-update 自动维护，无需也无法插值
- **例外：自维护 URL 的 update.sh**：geolite2、netboot-xyz 的 update.sh 自己 grep + sed 重写 URL 与哈希，字面量 URL 是脚本的工作前提，不要改成插值；改动这两个包时保持 update.sh 与 URL 字面量同步修改
- **非 GitHub 源**（webpage 抓取、AUR 等）：手写自定义更新脚本。脚本必须作为独立文件放在包目录下（如 `pkgs/uncategorized/baidunetdisk/update.sh`），不要内联在 default.nix 中；在包定义里用 `passthru.updateScript = [ (toString ./update.sh) ];` 引用。运行器以仓库根目录为 cwd 执行脚本，并设置 `UPDATE_NIX_ATTR_PATH`/`UPDATE_NIX_PNAME`/`UPDATE_NIX_NAME`/`UPDATE_NIX_OLD_VERSION` 环境变量；脚本内部获取新版本号后调用 `nix-update "$UPDATE_NIX_ATTR_PATH" --version "$NEW_VERSION"`（参考 `pkgs/uncategorized/baidunetdisk/update.sh`）
- **与基础包版本绑定的下游 overlay 包：自定义 update.sh + 版本闸门**：qemu-vmvga/nvkvm-pv 这类 overlay 只对某个精确的 QEMU 版本成立（补丁系列只保证能应用到该 release），其 `update.sh` 先 `nix eval --raw ".#${UPDATE_NIX_ATTR_PATH}.version"` 取当前基础包版本，再从上游 `releases.atom` 取最新 tag、用 `nix store prefetch-file --json --unpack` 解包后读取其中声明的基础 QEMU 版本（nvkvm 是 `scripts/build_qemu.sh` 里的 `QEMU_VERSION="..."`，qemu-vmvga 是 readme 里的 “based on QEMU X.Y.Z”）；只有两者一致才改写 tag/hash，否则打印 WARN 保持原状，避免把必定构建失败的 pin 提交进仓库（参考 `pkgs/lantian-customized/qemu/update.sh`）。解析 atom feed 的 tag 用 `grep -oP 'releases/tag/\K[^"]+'`：`\K` 无长度限制，而 `(?<=Repository/[0-9]+/)` 这类 lookbehind 在 PCRE 里会报 “length of lookbehind assertion is not limited”
- **禁止使用 api.github.com**（匿名限流 60 req/h，CI 里必挂）：版本探测一律用 atom feed 或 git 协议。tag/release 列表用 `https://github.com/<owner>/<repo>/{tags,releases}.atom`：tag 名从 `releases/tag/<tag>` 的 link href 或 `<id>tag:github.com,2008:Repository/<id>/<tag></id>` 解析。注意 atom feed 只含最近约 10 条，且 tags.atom 只列出附有 release 说明的 tag（无 release 的仓库如 zhoreeq/coredns-meshname，feed 为空）；需要完整 tag 列表时改用 `git ls-remote --tags <url>`（行尾 `^{}` 为 peeled 引用需过滤）。跟踪 HEAD 用 commits.atom 的 `<id>[^<]*/\K[0-9a-f]{40}`。releases feed 是最新在前，取 `tags[0]`；不要用字典序 sort 取“最新”（会把 0.9.0 排在 0.15.0 后）
- **nix-prefetch-url / nix-prefetch-git 已全部替换为 `nix store prefetch-file --json [--unpack] <url>`**：输出 JSON 的 `.hash` 为 SRI 格式（fetchurl/fetchFromGitHub 的 sha256 参数均接受 SRI，可与既有 base32 条目混存）。GitHub archive tarball 加 `--unpack` 的哈希与 fetchFromGitHub 一致，可替代 nix-prefetch-git；需要完整 git 克隆语义时才用 `nix-prefetch-git`
- **tarball prefetch 哈希对 `fetchSubmodules = true` 的源永远不匹配**：GitHub tarball 不含 git 子模块，`nix store prefetch-file --unpack` 算出的哈希只覆盖 worktree；而 `fetchFromGitHub { fetchSubmodules = true; }` 的 FOD 哈希包含子模块内容。更新脚本若用 tarball 哈希写这类条目，构建必挂。实例（2026-09-12）：nginx 的 `nginx-auth-jwt 0.15.0`/`nginx-oidc 0.8.0` 在 tag 升级时被写入 tarball 哈希（旧 tag 时代哈希是当初打包时用正确方法算的，脚本对"tag 未变"的条目从不重算哈希，故潜伏到下次 tag 变更才爆炸）；qsp 的 update.sh 更是用 `nix store prefetch-file --json`（连 `--unpack` 都没有，等于 tarball **文件**哈希）计算 qsp-wx（fetchSubmodules=true）哈希，所幸 rev 未变过才未爆雷。**也不能改用 `nix flake prefetch 'git+...?submodules=1'`**：其 narHash 与 fetchFromGitHub 的 FOD 哈希在部分仓库一致（kjdev/nginx-oidc、nginx-auth-jwt 实测一致）但并非普适（wxWidgets@5d63efc9 实测不一致），一致性无保证。唯一可靠方法是**用包自身相同的 fetcher 计算哈希**（nix-update 内部同款）：以 dummy 哈希 `sha256-AAAA...` 构建该 fetchFromGitHub FOD，从报错 `got:` 行取真实哈希，最后 `nix build .#<pkg>.src` 收尾验证。已落地：nginx 的 update-standalone.sh 对 fetchSubmodules 条目**每次运行都重算哈希**（自愈既有错哈希）、qsp 的 update.sh 改用 FOD-echo；openssl-oqs-provider 弃用 unstableGitUpdater，改用自带 update.sh（commits.atom 取 rev/日期 + ls-remote 取 tag + prefetch-file 算哈希 + `nix build .#$ATTR.src` 验证，version 仅在 rev 变化时更新，规避上条的 tempHash 卡死）
- **更新脚本只在版本变化时写哈希 = 既有哈希永远不被校验**：上游内容漂移（如旧 tag 上新增 `.gitmodules`、re-tag）或脚本自身写错哈希都不会被更新流程发现，只有等构建失败才暴露。写哈希的脚本必须在写入后（或每次运行时对易错条目）做一次真实构建验证，把哈希错误挡在提交之前，而不是依赖 CI 构建兜底
- **跟踪上游 HEAD 的包依赖另一依赖的 git HEAD 时，buildInputs 必须用对应的 unstable 包而非 release 版**（openssl-oqs-provider 实例，2026-09-19）：oqs-provider HEAD 升级了 SNOVA/MAYO/MQOM round-3 参数集，引用的 `OQS_SIG_alg_snova_SNOVA_I_K` 等符号只存在于 liboqs git HEAD，而仓库内默认 `liboqs` 是 0.16.0 release，编译报 `undeclared identifier`。修复是把 buildInputs 从 `liboqs` 换成 `liboqs-unstable`（同一包集内 callPackage 可见）。nginx 对 openssl-oqs-provider 的消费只是读取其源码生成 oqs_lookup.c（ALGORITHMS.md 正则），与 liboqs 无关，切换安全。排查方法：从包源码 `grep -rhoE 'OQS_(SIG|KEM|SIG_STFL)_alg_[A-Za-z0-9_]+'` 收集全部符号，逐个在依赖 HEAD 的头文件（`src/kem/kem.h`、`src/sig/sig.h` 等）里核对
- **不要用 `bash xxx.py` 运行 python 更新脚本**：shebang 会被绕过，python 源码会被当 shell 逐行执行，`import json` 会命中 ImageMagick 的 `import` 命令在当前目录生成截图文件。验证时直接 `./xxx.py` 执行（shell 脚本同理，见上文 nix-update 条目）
- **nix-update 可自动识别的 fetchurl 源**：除了 GitHub releases，`registry.npmjs.org` 的 npm tarball URL 也能被 nix-update 自动探测最新版本（含 scoped 包），可直接用 `nix-update-script { }`
- **版本/src 在内层派生时需提升到顶层**：若 version 和 src 定义在 let 绑定的内层 `mkDerivation`（如 wine-wechat 的 wechatFiles），顶层求值结果没有 `src` 属性，nix-update 无法工作。重构方法：把 `version = "..."` 和 `src = fetchurl { ... }` 直接放在顶层 `stdenv.mkDerivation (finalAttrs: { ... })` 里（外层配 `dontUnpack = true` 即可，不影响构建）；内层派生通过 `inherit (finalAttrs) version src;` 引用同一份定义；原先依赖内层派生的 let 绑定（启动脚本等）移入使用它们的 phase（如 postInstall）内的局部 let。URL 用 `${finalAttrs.version}` 插值（见上条：字面量 URL 不会被 nix-update 改写）
- **多源同版本的去重**：同一文件里多个派生共享同一 GitHub 源（如 axonhub 的 frontendPnpmDeps/frontendDist/主程序、it-tools 的 pnpmDeps）时，在 let 里定义 `version = "...";` 与 `src = fetchFromGitHub { tag = "v${version}"; ... }`，各派生 `inherit version src;`，保证 nix-update 只需改一处版本字面量（`inherit version;` 行不含字面量时走全文件独立带引号串替换路径，let 绑定会被正确更新）
- **依赖哈希必须暴露为顶层 passthru 属性，否则 nix-update 不会更新**：nix-update 从顶层包的属性读取依赖哈希（`pkg.pnpmDeps.outputHash`、`pkg.goModules.outputHash`、`pkg.npmDeps.outputHash` 等，见 nix-update 的 `eval.nix`/`dependency_hashes.py`），只更新它看得见的。像 axonhub 那样把 `frontendPnpmDeps = fetchPnpmDeps { ... }` 放在 let 里、由中间派生 frontendDist 消费的模式，nix-update 完全看不到，版本升级后 pnpmDeps 哈希永远静默过期。修复：`passthru.pnpmDeps = frontendPnpmDeps;`（it-tools 直接把 pnpmDeps 写在顶层 mkDerivation 上所以没这个问题；resin 同理用 `passthru.npmDeps = frontendDist.npmDeps;`）。同时注意 nix-update 的哈希更新顺序里 pnpmDeps 在 goModules 之前：若 pnpmDeps 过期，goModules 预取构建会先因依赖（frontend-pnpm-deps）失败而中止，`extract_hash_from_nix_error` 从报错 stderr 里抓**最后一个** `got:` 哈希写入 vendorHash——实测它会把 pnpm store 的哈希写进 vendorHash 字段（axonhub 曾因此 vendorHash 变成 pnpm 哈希）。暴露 pnpmDeps 后顺序保证先修复 pnpmDeps 再预取 goModules，可避免此污染
- **nix-update 的依赖哈希替换是字面串替换，`lib.fakeHash` 永远修不好**：`dependency_hashes.py` 的 `replace_hash` 拿到的是**求值后**的旧哈希（`lib.fakeHash` → `sha256-AAAAAAAA...=`）然后在文件里逐行做 `str.replace`，文件里若写的是 `lib.fakeHash` 就一次也匹配不上，替换静默 no-op —— 版本、src 哈希都升级了，cargoHash 仍是假的，只有等到构建失败才暴露。因此凡是打算用 nix-update 维护的依赖哈希（`cargoHash`/`vendorHash`/`npmDepsHash`/`pnpmDeps`/`goModules` 等）**必须写成字面量哈希字符串**（可以是故意错误的占位值），不能用 `lib.fakeHash`。验证方法：把 `version` 改成一个旧值、哈希改成另一个合法字面量，跑一次更新脚本，确认两者都被改回当前值（skyline-speeder 实测如此）
- **固定输出派生的静默陈旧复用**：FOD（fetchPnpmDeps/goModules 等）的输出路径由 `name + 声明哈希` 决定、与派生其余输入无关。若声明哈希是旧 lockfile 时代算出来的，且旧 FOD 的输出还在本地/远端 builder 的 store 里，则换了新 src 的新派生会因输出路径同名同哈希而**直接复用旧输出、跳过重新下载**，不报哈希不匹配。症状：构建时报 `ERR_PNPM_NO_OFFLINE_TARBALL`（store 里缺少 lockfile 新增的包，且 store 里混着新旧两个版本的包索引）。修复：把哈希清空重建拿到真实哈希写回。这也意味着“构建成功”不代表 FOD 内容与当前 lockfile 一致
- **跟踪 git HEAD 且有依赖哈希的包一律用 nix-update-script --version branch，不用 unstableGitUpdater**：`unstableGitUpdater`（update-source-version）只处理 version/rev/src hash，不更新 vendorHash/cargoHash/npmDepsHash，上游依赖变了会静默过期（oidc-tester-app 的 vendorHash、resin 的 npmDepsHash 曾因此构建失败）。已把所有带依赖哈希的 unstableGitUpdater 用户迁移到 `nix-update-script { extraArgs = [ "--version" "branch" ]; }`（baidupcs-go、drone-file-secret、ldap-auth-proxy、pterodactyl-wings、fake-ollama、helium-gateway-rs、sidestore-vpn、linguaspark-server、hack3ric-flow）。branch 模式从分支 atom feed 取 HEAD 日期，并用 releases feed 的最新 tag 数字作版本前缀（无 tag 仓库自动得 `0-unstable-<日期>`，等效 hardcodeZeroVersion），同一次运行里更新 rev/src hash 并预取 goModules/cargoDeps 刷新依赖哈希。无依赖哈希的包（内核模块、字体、词典、纯 Python 包等）可继续用 unstableGitUpdater。注意事项：(1) atom feed 日期取 entry 的 `updated` 字段，与 unstableGitUpdater 的 committer date 可能相差一天（fake-ollama 实测出现过日期回退）；(2) 仓库 releases 混入无关 tag 时版本前缀会失真，需改用 version-regex 或 unstableGitUpdater 的 tagFormat/tagConverter；(3) 迁移前用 `git ls-remote --tags` 和 releases.atom 确认版本前缀格式不变
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
- 包目录下的 `update-standalone.*`：需要 `passthru.updateScript` 机制无法支持的复杂更新逻辑的包（如多源 sources.json 包：`helpers/update.nix` 运行器的 `usesSources` 检查会跳过 default.nix 中含 `sources.` 引用的包，nix-update 也只支持单一 version/src），由顶层 `update` 命令的 find 循环直接执行。脚本必须自包含：不依赖 `UPDATE_NIX_*` 环境变量（find 循环不注入），自行从上游探测新旧版本（如 GitHub releases atom feed），无更新时静默退出

### 已知限制

- 上游 git 子模块使用 SSH URL（如 `git@github.com:...`）的包无法被 nix-update 重新计算哈希；此类包应写独立 update.sh 自行计算哈希，或保持手动更新
- 包装类包（override nixpkgs 包、无独立 src，如 lantianCustomized.materialgram/firefox-unwrapped/attic-telnyx-compatible、uncategorized.wechat-uos-sandboxed/nftables-fullcone/libnftnl-fullcone）继承自 nixpkgs 的 updateScript 在本仓库无法正确运行，已在 `helpers/update.nix` 的 `excludes` 列表中排除，它们跟随 nixpkgs flake 锁更新
- python-packages 组的包因 nixpkgs `buildPythonPackage` 自动注入 `passthru.updateScript`，未迁移的包会被运行器的 `sources.` 过滤器跳过

## 源码管理

- 源码不再由集中式工具（nvfetcher）管理；每个包在自身目录内联 fetcher 并声明 `passthru.updateScript`
- 多源包使用 `sources.json` + `importJSON`/`fromJSON`（如 fr24feed、qemu-user-static），由包内 `update.sh` 整体重写
- 顶层 `update` 命令流程：`nix flake update` → 执行 `pkgs/**/update-standalone.*` → `./tools/update-package --all` → 重新生成 README。单个包更新失败（update-standalone 脚本或 update-package 内的个别包）不会中断流程，README 仍会在最后重新生成；命令退出码保留失败状态供 CI 报警

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
