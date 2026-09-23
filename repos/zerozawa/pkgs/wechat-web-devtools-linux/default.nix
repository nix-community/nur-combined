# Source build of msojocs/wechat-web-devtools-linux, mirroring the upstream CI
# (.github/workflows/build-src.yml -> tools/setup-wechat-devtools.sh) on the
# commit the rolling `continuous` release points at (upstream retires the
# continuous branch between Electron milestones; the release tag is the stable
# reference).
# Upstream moved from NW.js to Electron (conf/config.json: electron 36.6.0,
# node 22.16.0, devtools 2.02.2608070); this derivation mirrors the Electron
# pipeline: 7z-extract resources from the Windows installer, asar unpack,
# rebuild native modules with node-gyp (electron headers for electron-side
# modules, node headers for node-side ones), asar pack with upstream's unpack
# globs, then the fix-* patches (package name, cli, skill, bootstrap/config,
# wcc/wcsc, float-pigment, webview touch-focus/mouse-leave).
# Since 2.02.2608070-2 upstream dropped its bundled node runtime: bin/node runs
# the Electron binary with ELECTRON_RUN_AS_NODE=1, so no node runtime is staged
# into electron/ (node headers are still needed for the node-side gyp modules).
# Desktop entry fields mirror upstream res/deb.desktop; icons come from
# upstream res/icons.
# npm/ holds hand-written manifests + lockfiles for the native-module rebuild
# step: upstream runs a floating `npm install <list>` in
# tools/rebuild-node-modules.sh with no package.json/lockfile, which is not
# reproducible; the manifests here mirror that install list (same pins:
# nodegit@0.28.0-alpha.36, node-pty@1.0.0, @vscode/spdlog@0.13.11, ...) so
# fetchNpmDeps can fetch offline.
{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  fetchNpmDeps,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  autoPatchelfHook,
  nodejs,
  p7zip,
  unzip,
  cmake,
  python3,
  pkg-config,
  glib,
  nss,
  nspr,
  at-spi2-core,
  at-spi2-atk,
  cups,
  libdrm,
  dbus,
  expat,
  alsa-lib,
  libxdamage,
  libxcomposite,
  libxshmfence,
  libxcb,
  libxkbcommon,
  libX11,
  libxext,
  libxfixes,
  libxrandr,
  libgbm,
  libGL,
  pango,
  cairo,
  gtk3,
  libxkbfile,
  krb5,
  systemd,
  mesa,
  curl,
  openssl,
  ...
}:
let
  # conf/config.json on the continuous branch
  nodeVersion = "22.16.0";
  electronVersion = "36.6.0";
  compilerVersion = "0.2.0";
  devtoolsVersion = "2.02.2608070";

  # node 运行时不再打进 electron/：上游 bin/node 现在以 ELECTRON_RUN_AS_NODE
  # 复用 electron 二进制（CHANGELOG 2.02.2608070-2 "refactor: 移除node依赖"）。
  nodeHeaders = fetchurl {
    url = "https://nodejs.org/dist/v${nodeVersion}/node-v${nodeVersion}-headers.tar.gz";
    hash = "sha256-pg5aVD+rXlEFUllIxZbUl0xhfzlgbO9265TDvx35oGw=";
  };
  electronTarball = fetchurl {
    url = "https://github.com/electron/electron/releases/download/v${electronVersion}/electron-v${electronVersion}-linux-x64.zip";
    hash = "sha256-ag3ss+OC8y1Ks9uQqr0ILvnuEVT+IFgI+IfiKP2y01U=";
  };
  electronHeaders = fetchurl {
    url = "https://artifacts.electronjs.org/headers/dist/v${electronVersion}/node-v${electronVersion}-headers.tar.gz";
    hash = "sha256-EXE7YX7yd1DJJxarSgzvMLS/Ld1rc57pXeX5GKh/StU=";
  };
  # 上游 conf/config.json 用的就是 wxqcloud 这个 host；dldir1 对 GitHub runner
  # 时通时不通（2026-09-23 CI: curl (28) Failed to connect after 135s），
  # 两个 host 的字节完全相同（sha256 a502dead…），所以 mirror 优先 + 备用。
  devtoolsExe = fetchurl {
    urls = [
      "https://devtools.wxqcloud.qq.com.cn/WechatWebDev/release/be1ec64cf6184b0fa64091919793f068/wechat_devtools_${devtoolsVersion}_win32_x64.exe"
      "https://dldir1.qq.com/WechatWebDev/release/be1ec64cf6184b0fa64091919793f068/wechat_devtools_${devtoolsVersion}_win32_x64.exe"
    ];
    hash = "sha256-pQLerS5PttywteFX4fK5rADBCiDxlAkXESofhIHtXtk=";
  };
  ripgrepTarball = fetchurl {
    url = "https://github.com/microsoft/ripgrep-prebuilt/releases/download/v15.0.0/ripgrep-v15.0.0-x86_64-unknown-linux-musl.tar.gz";
    hash = "sha256-ndkwaixEzdox4vTzzzb01xSCYNk3FoPpZdPImSwgU0k=";
  };
  wccBin = fetchurl {
    url = "https://github.com/msojocs/wx-compiler/releases/download/v${compilerVersion}/wcc-x86_64";
    hash = "sha256-b/ayhhEbEzEIDrbbOE4J7FD8wcqdjzGCGbrPrm3z9tY=";
  };
  wcscBin = fetchurl {
    url = "https://github.com/msojocs/wx-compiler/releases/download/v${compilerVersion}/wcsc-x86_64";
    hash = "sha256-RblFu1hBsdfJWwH6al77L/JVTt5Y8A0aB8g79YSQExs=";
  };
  wccNode = fetchurl {
    url = "https://github.com/msojocs/wx-compiler/releases/download/v${compilerVersion}/wcc-x86_64.node";
    hash = "sha256-bV3gKfcMIXHaUf6JwgV6VWSyqAJM4DbfIZV2A8rdfz4=";
  };
  wcscNode = fetchurl {
    url = "https://github.com/msojocs/wx-compiler/releases/download/v${compilerVersion}/wcsc-x86_64.node";
    hash = "sha256-xSks4zTQV97V8WnVL+XNjX5h8OXuqFngZcA+K1dpUW0=";
  };
  floatPigmentNode = fetchurl {
    url = "https://github.com/msojocs/float-pigment-rust/releases/download/continuous/float-pigment.linux-x64-gnu.node";
    hash = "sha256-A7ipWEYvUnNTWpqWAQntjb8NSfkrPW3MkMIa4ULgVK0=";
  };

  nativeNpmDeps = fetchNpmDeps {
    src = ./npm/native;
    hash = "sha256-Axv9SVMJyDwG0k869L07AvdLnMSgIxAv8ewFqzgjTPQ=";
  };
  toolsNpmDeps = fetchNpmDeps {
    src = ./npm/tools;
    hash = "sha256-lPh0gqM5Vh6D5/PyI+KeOZWCWWDisurwY9i0wQtwG4A=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "wechat-web-devtools-linux";
  version = "0-unstable-c399c6c";

  src = fetchFromGitHub {
    owner = "msojocs";
    repo = "wechat-web-devtools-linux";
    rev = "c399c6c3b0c10409b7ae441db828b6f35b3e2f1d";
    hash = "sha256-h1e1hIWFctlX7x8ysHymQ/DUwnEa00dqAYXDdRMN8as=";
  };

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
    autoPatchelfHook
    nodejs
    p7zip
    unzip
    cmake
    python3
    pkg-config
  ];

  buildInputs = [
    glib
    nss
    nspr
    at-spi2-core
    at-spi2-atk
    cups
    libdrm
    dbus
    expat
    alsa-lib
    libxcb
    libxkbcommon
    libxkbfile
    libX11
    libxext
    libxfixes
    libxrandr
    libgbm
    libGL
    pango
    cairo
    gtk3
    krb5
    systemd
    mesa
    curl
    libxdamage
    libxcomposite
    libxshmfence
    openssl
  ];

  # cmake 仅用于 nodegit 的 libssh2 configure，不构建本项目
  dontUseCmakeConfigure = true;

  # 忽略 musl libc，因为这是 @swc/core 的可选依赖
  autoPatchelfIgnoreMissingDeps = [
    "libc.musl-x86_64.so.1"
  ];

  # gyp builds: electron 36 headers require C++20, node 22 headers C++17 —
  # each headers' common.gypi sets the right -std, so do not pin CXXFLAGS.
  # 捆绑的 C 代码（libgit2/libssh2）在 GCC15 下 incompatible-pointer-types 变为错误，降级回警告
  env.CFLAGS = "-Wno-error=incompatible-pointer-types -Wno-incompatible-pointer-types";
  env.CXXFLAGS = "-Wno-error=incompatible-pointer-types -Wno-incompatible-pointer-types";

  buildPhase = ''
    runHook preBuild

    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"
    ROOT="$PWD"

    # ── 依赖解包 ─────────────────────────────
    # node 头文件（node-gyp --nodedir 用，include/node 布局）
    mkdir -p deps/node-headers
    tar xf ${nodeHeaders} -C deps/node-headers --strip-components=1

    # electron 头文件（node-gyp --nodedir 用，config.gypi 带 built_with_electron）
    mkdir -p deps/electron-headers
    tar xf ${electronHeaders} -C deps/electron-headers --strip-components=1

    # electron 运行时
    mkdir -p electron
    unzip -q ${electronTarball} -d electron

    # 微信开发者工具 Windows 安装包 -> resources（app.asar + vsextensions 等）
    mkdir -p deps/exe
    7z x ${devtoolsExe} -o"deps/exe" "resources" -y
    mv deps/exe/resources resources
    chmod -R u+rwX resources

    # node-gyp + asar 工具链（npm ci 离线安装）
    mkdir -p deps/tools
    cp ${./npm/tools}/package.json ${./npm/tools}/package-lock.json deps/tools/
    chmod u+w deps/tools/*
    cp -r ${toolsNpmDeps} "$TMPDIR/tools-cache"
    chmod -R u+w "$TMPDIR/tools-cache"
    npm ci --prefix deps/tools --ignore-scripts --offline --cache "$TMPDIR/tools-cache"
    NODE_GYP="node $ROOT/deps/tools/node_modules/node-gyp/bin/node-gyp.js"
    ASAR="node $ROOT/deps/tools/node_modules/asar/bin/asar"

    # ── asar 解包（asar-helper.sh unpack） ──
    pushd resources
    $ASAR extract app.asar app
    rm -rf app.asar app.asar.unpacked
    popd

    # ── 重建原生模块（rebuild-node-modules.sh 改编） ──
    pushd resources/app/node_modules
    rm -fr vscode-windows-ca-certs \
           vscode-windows-registry \
           vscode-windows-registry-node \
           windows-process-tree
    find . -name "*.pdb" -delete
    find . -name "*.lib" -delete
    find . -name "*.dll" -delete
    find . -name "*.exe" -delete
    rm -fr "@vscode/ripgrep/bin/"*
    mkdir -p "@vscode/ripgrep/bin"
    tar xf ${ripgrepTarball} -C "@vscode/ripgrep/bin"
    popd

    # 待重编译模块源码（npm ci 离线安装）
    mkdir -p resources/app/node_modules_tmp
    cp ${./npm/native}/package.json ${./npm/native}/package-lock.json resources/app/node_modules_tmp/
    chmod u+w resources/app/node_modules_tmp/*
    cp -r ${nativeNpmDeps} "$TMPDIR/native-cache"
    chmod -R u+w "$TMPDIR/native-cache"
    npm ci --prefix resources/app/node_modules_tmp --ignore-scripts --offline --cache "$TMPDIR/native-cache"

    build_module() {
      # $1 = 模块目录, $2 = --nodedir, $3 = --target
      pushd "$1"
      $NODE_GYP configure --nodedir="$2" --target="$3" --arch=x64 --verbose
      $NODE_GYP build -j"$NIX_BUILD_CORES"
      popd
    }

    # nodegit 需要 openssl 头文件/库（electron 动态链接 -lcrypto -lssl）；
    # npm_config_openssl_dir 同时跳过 acquireOpenSSL 的源码构建
    mkdir -p resources/app/node_modules_tmp/node_modules/nodegit/vendor/openssl
    cp -r ${openssl.dev}/include resources/app/node_modules_tmp/node_modules/nodegit/vendor/openssl/
    cp -r ${openssl.out}/lib resources/app/node_modules_tmp/node_modules/nodegit/vendor/openssl/
    export npm_config_openssl_dir="$ROOT/resources/app/node_modules_tmp/node_modules/nodegit/vendor/openssl"

    pushd resources/app/node_modules_tmp/node_modules

    # electron 侧模块（ABI 135）
    build_module nodegit "$ROOT/deps/electron-headers" "v${electronVersion}"
    chmod -R u+w nodegit/vendor
    pushd nodegit
    rm -rf .github include src lifecycleScripts vendor utils build/vendor build/Release/.deps
    popd
    build_module node-pty "$ROOT/deps/electron-headers" "v${electronVersion}"
    build_module "@vscode/spdlog" "$ROOT/deps/electron-headers" "v${electronVersion}"
    ( cd "@vscode" && build_module sqlite3 "$ROOT/deps/electron-headers" "v${electronVersion}" )

    # node 侧模块（ABI 127）
    build_module extract-file-icon "$ROOT/deps/node-headers" "v${nodeVersion}"
    build_module native-keymap "$ROOT/deps/node-headers" "v${nodeVersion}"
    build_module native-watchdog "$ROOT/deps/node-headers" "v${nodeVersion}"

    # 清理编译产物
    find . -name ".deps" | xargs -r rm -rf
    find . -name "obj.target" | xargs -r rm -rf
    find . -name "*.a" -delete
    find . -name "*.lib" -delete
    find . -name "*..mk" -delete

    # .node 回写到 app/node_modules（保持相对路径）
    find . -name "*.node" | while read -r f; do
      cp --parents -f "$f" "$ROOT/resources/app/node_modules/"
    done
    popd
    rm -rf resources/app/node_modules_tmp

    # ── 补丁：包名 / CLI / bootstrap / wcc / float-pigment ──
    # fix-package-name.js（srcdir 指向构建目录）
    srcdir="$ROOT" node "$src/tools/fix-package-name.js"

    # fix-cli.sh 内联（prepend res/scripts/cli.js）
    cat "$src/res/scripts/cli.js" resources/app/js/common/cli/index.js > "$TMPDIR/cli.js"
    cat "$TMPDIR/cli.js" > resources/app/js/common/cli/index.js

    # fix-skill.sh 内联（prepend skill-index.js / append install-root.js）
    cat "$src/res/scripts/skills/skill-index.js" resources/app/js/common/cli/skill-index.js > "$TMPDIR/skill-index.js"
    cat "$TMPDIR/skill-index.js" > resources/app/js/common/cli/skill-index.js
    cat resources/app/wechatide-skill/skills/installer/scripts/install-root.mjs "$src/res/scripts/skills/install-root.js" > "$TMPDIR/install-root.mjs"
    cat "$TMPDIR/install-root.mjs" > resources/app/wechatide-skill/skills/installer/scripts/install-root.mjs

    # fix-compiler.sh 内联（prepend bootstrap.js + config.js）
    cat "$src/res/scripts/bootstrap.js" resources/app/js/electron/backend/bootstrap.js > "$TMPDIR/bootstrap.js"
    cat "$TMPDIR/bootstrap.js" > resources/app/js/electron/backend/bootstrap.js
    cat "$src/res/scripts/config.js" resources/app/js/common/miniprogram-builder/modules/corecompiler/original/workerThread/config.js > "$TMPDIR/config.js"
    cat "$TMPDIR/config.js" > resources/app/js/common/miniprogram-builder/modules/corecompiler/original/workerThread/config.js

    # fix-webview-touch-focus.js（模拟器需点击两次；版本相关模块校验后追加补丁）
    node "$src/tools/fix-webview-touch-focus.js" resources/app

    # wcc/wcsc 替换为 Linux 版本
    cp ${wccBin} resources/app/node_modules/wcc-exec/wcc
    cp ${wcscBin} resources/app/node_modules/wcc-exec/wcsc
    chmod +x resources/app/node_modules/wcc-exec/wcc resources/app/node_modules/wcc-exec/wcsc
    rm -rf resources/app/node_modules/wcc-exec/wcc.exe resources/app/node_modules/wcc-exec/wcsc.exe

    # 可视化用 wcc/wcsc .node
    rm -rf resources/app/node_modules/wcc-electron/build/Release/wcc.node
    cp ${wccNode} resources/app/node_modules/wcc-electron/build/Release/wcc.node
    rm -rf resources/app/node_modules/wcc-electron/build/Release/wcsc.node
    cp ${wcscNode} resources/app/node_modules/wcc-electron/build/Release/wcsc.node

    # Skyline 解析插件修复（fix-other.sh）
    rm -f resources/app/node_modules/node-float-pigment-css/float-pigment-css-for-nodejs.node \
          resources/app/node_modules/node-float-pigment-css/float-pigment-css-for-nwjs.node
    cp ${floatPigmentNode} resources/app/node_modules/node-float-pigment-css/float-pigment-css-for-nodejs.node
    cp ${floatPigmentNode} resources/app/node_modules/node-float-pigment-css/float-pigment-css-for-nwjs.node

    # ── asar 打包（asar-helper.sh pack，上游 unpack globs） ──
    pushd resources
    $ASAR pack app app.asar --unpack "{**/bin/**,**/js/unpack/**,**/js/common/fileutils/unpack/**,**/js/common/cli/index.js,**/js/common/cli/skill-error-rules.js,**/js/common/cli/skill-index.js,**/js/common/cli/skill-outcome.js,**/js/common/cloud-functions-debugger-server/worker/node.js,**/js/common/miniprogram-builder/static/scripts/assetsCar/**,**/js/common/miniprogram-builder/static/scripts/checkXcodeEnv,**/js/common/miniprogram-builder/static/scripts/resignIpa,**/wechatide-skill/**,**/*.node,**/*.exe,**/*.dll,**/*.so,**/ios-deploy,**/node_modules/trash/lib/macos-trash,**/node_modules/skyline-addon/**,**/node_modules/wcc-exec/**,**/ripgrep/bin/**,package.json}"
    rm -rf app
    popd

    # 构建时间戳（固定值，保证可复现；启动脚本仅用于缓存失效判断）
    echo "${finalAttrs.version}" > resources/.build_time
    echo "${finalAttrs.version}" > resources/app.asar.unpacked/.build_time

    # ── electron 组装（build-src.yml Compress Resources） ──
    # node 运行时不再随 electron 分发：bin/node 以 ELECTRON_RUN_AS_NODE 复用 electron
    rm -rf electron/resources
    ln -s ../resources electron/resources

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -d "$out/opt/${finalAttrs.pname}"
    install -d "$out/bin"
    cp -a bin electron resources "$out/opt/${finalAttrs.pname}/"
    ln -s $out/opt/${finalAttrs.pname}/bin/wechat-devtools $out/bin/${finalAttrs.pname}
    ln -s $out/opt/${finalAttrs.pname}/bin/wechat-devtools-cli $out/bin/${finalAttrs.pname}-cli
    for size in 16 32 48 64 96 128 256 512; do
      install -Dm644 "$src/res/icons/''${size}x''${size}.png" \
        "$out/share/icons/hicolor/''${size}x''${size}/apps/wechat-devtools.png"
    done
    install -Dm644 "$src/res/icons/wechat-devtools.svg" \
      "$out/share/icons/hicolor/scalable/apps/wechat-devtools.svg"
  ''
  + (lib.concatStringsSep "\n" (
    lib.map
      (x: ''
        wrapProgram ${x} \
          --prefix LD_LIBRARY_PATH : "$out/opt/${finalAttrs.pname}/electron" \
          --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath finalAttrs.buildInputs} \
          --set LIBGL_DRIVERS_PATH "${mesa}/lib/dri"
      '')
      [
        "$out/bin/${finalAttrs.pname}"
        "$out/bin/${finalAttrs.pname}-cli"
      ]
  ))
  + "\nrunHook postInstall";

  desktopItems = [
    # 与上游 res/deb.desktop 一致（Exec 改为 PATH 内 wrapper 名）
    (makeDesktopItem {
      name = "wechat-devtools";
      desktopName = "WeChat Dev Tools";
      comment = "The development tools for wechat projects";
      exec = "${finalAttrs.pname} %U";
      icon = "wechat-devtools";
      terminal = false;
      type = "Application";
      startupWMClass = "wechat-devtools";
      categories = [
        "Development"
        "WebDevelopment"
        "IDE"
      ];
      mimeTypes = [ "x-scheme-handler/wechatide" ];
      extraConfig = {
        "Name[zh_CN]" = "微信开发者工具";
        "Comment[zh_CN]" = "提供微信开发相关项目的开发IDE支持";
      };
    })
  ];

  meta = with lib; {
    description = "微信开发者工具 Linux版";
    homepage = "https://github.com/msojocs/wechat-web-devtools-linux";
    license = with licenses; [ mit ];
    platforms = with platforms; (intersectLists x86_64 linux);
    mainProgram = "wechat-web-devtools-linux";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
  };
})
