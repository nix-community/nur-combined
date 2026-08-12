# Source build of msojocs/wechat-web-devtools-linux, mirroring the upstream CI
# (.github/workflows/build-src.yml -> tools/setup-wechat-devtools.sh) on the
# continuous branch, which upstream now uses instead of versioned releases.
# Desktop entry fields mirror upstream res/deb.desktop; icons come from
# upstream res/icons.
# npm/ holds hand-written manifests + lockfiles for the native-module rebuild
# step: upstream runs a floating `npm install <list>` in
# tools/rebuild-node-modules.sh with no package.json/lockfile, which is not
# reproducible; the manifests here mirror that install list (same pins:
# node-pty@1.0.0, @vscode/spdlog@0.13.11) so fetchNpmDeps can fetch offline.
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
  ...
}:
let
  # conf/config.json on the continuous branch
  nodeVersion = "16.13.1";
  nwjsVersion = "0.55.0";
  compilerVersion = "0.1.7";
  devtoolsVersion = "2.01.2510290";
  sharedMemoryVersion = "1.0.4";
  skylineVersion = "2.01.2510280-1";

  nodeTarball = fetchurl {
    url = "https://nodejs.org/dist/v${nodeVersion}/node-v${nodeVersion}-linux-x64.tar.gz";
    hash = "sha256-X4AZfWVP0LdJze3fHwel6sH89rQjoA/8jy076pxtyNE=";
  };
  nodeHeaders = fetchurl {
    url = "https://nodejs.org/dist/v${nodeVersion}/node-v${nodeVersion}-headers.tar.gz";
    hash = "sha256-8hAc3wXdBAOXAAWW7Q8oXf90qSZjfP6rq46Yu3umcyc=";
  };
  nwjsTarball = fetchurl {
    url = "https://dl.nwjs.io/v${nwjsVersion}/nwjs-sdk-v${nwjsVersion}-linux-x64.tar.gz";
    hash = "sha256-HvZWxVBwmWCoB2oEB8Z4RTkrWBHB959WSn1yPr+Rr/g=";
  };
  nwHeaders = fetchurl {
    url = "https://dl.nwjs.io/v${nwjsVersion}/nw-headers-v${nwjsVersion}.tar.gz";
    hash = "sha256-1cXw7mJ3weYv5d+35M+hbZModex+5jJbEV5HZWuU/sg=";
  };
  devtoolsExe = fetchurl {
    url = "https://dldir1.qq.com/WechatWebDev/release/be1ec64cf6184b0fa64091919793f068/wechat_devtools_${devtoolsVersion}_win32_x64.exe";
    hash = "sha256-+BfbjdccmpsnWDwYoXwwAUQxQWLKe3+US2JixFixJ/c=";
  };
  ripgrepTarball = fetchurl {
    url = "https://github.com/microsoft/ripgrep-prebuilt/releases/download/v15.0.0/ripgrep-v15.0.0-x86_64-unknown-linux-musl.tar.gz";
    hash = "sha256-ndkwaixEzdox4vTzzzb01xSCYNk3FoPpZdPImSwgU0k=";
  };
  wccBin = fetchurl {
    url = "https://github.com/msojocs/wx-compiler/releases/download/v${compilerVersion}/wcc-x86_64";
    hash = "sha256-yR2YN4WfxWIFjxxCOgVs3iBnwB+drU50eB2mCc+YgV0=";
  };
  wcscBin = fetchurl {
    url = "https://github.com/msojocs/wx-compiler/releases/download/v${compilerVersion}/wcsc-x86_64";
    hash = "sha256-fKcvuC3yG2xrzF+6zIgJzjDciFK2/jvcXjNxbKUegao=";
  };
  wccNode = fetchurl {
    url = "https://github.com/msojocs/wx-compiler/releases/download/v${compilerVersion}/wcc-x86_64.node";
    hash = "sha256-creU26/ACSaeb+m4rPh+1CrxD6tP4iAHwKUAoU6MPxM=";
  };
  wcscNode = fetchurl {
    url = "https://github.com/msojocs/wx-compiler/releases/download/v${compilerVersion}/wcsc-x86_64.node";
    hash = "sha256-2/7X/tB2TRjbW8gvYP6gdDc+bsjopb0IwXXXNOJMzFY=";
  };
  libffmpegZip = fetchurl {
    url = "https://github.com/nwjs-ffmpeg-prebuilt/nwjs-ffmpeg-prebuilt/releases/download/${nwjsVersion}/${nwjsVersion}-linux-x64.zip";
    hash = "sha256-M/dzdFlXGM91xJjyrv3/eYLacR4KA47Yu+essB1Lru4=";
  };
  floatPigmentNode = fetchurl {
    url = "https://github.com/msojocs/float-pigment-rust/releases/download/continuous/float-pigment.linux-x64-gnu.node";
    hash = "sha256-A7ipWEYvUnNTWpqWAQntjb8NSfkrPW3MkMIa4ULgVK0=";
  };
  sharedMemoryNode = fetchurl {
    url = "https://github.com/msojocs/skyline-shared-memory/releases/download/v${sharedMemoryVersion}/skyline-sharedMemory-linux-x86_64-v${sharedMemoryVersion}.node";
    hash = "sha256-25KB22/MiBDbgVkTesJBiFJyZYcHy7OTML35aB3Db3A=";
  };
  skylineClientNode = fetchurl {
    url = "https://github.com/msojocs/skyline-client-server/releases/download/v${skylineVersion}/skyline-client-linux-x86_64-v${skylineVersion}.node";
    hash = "sha256-zSrO4zhe+YX1ENFS7BXgVG1BQEtSI/PY0GHYaK70YQM=";
  };

  nativeNpmDeps = fetchNpmDeps {
    src = ./npm/native;
    hash = "sha256-wHfwx25zQaPjZHbPVlOQQww95TLtaaP8W5CWel2v384=";
  };
  toolsNpmDeps = fetchNpmDeps {
    src = ./npm/tools;
    hash = "sha256-0l9VymWb1SZYDwPBrE0OqJV8V4//kbF89NaStCzv0/Y=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "wechat-web-devtools-linux";
  version = "0-unstable-975b2fd";

  src = fetchFromGitHub {
    owner = "msojocs";
    repo = "wechat-web-devtools-linux";
    rev = "975b2fd676bb8931e762cfd93792df423f44ff4a";
    hash = "sha256-XPlAW9G2xbPc0Gj9KnvLlYIWeEQV6oimQ854UnOSUaE=";
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
  ];

  # cmake 仅用于 nodegit 的 libssh2 configure，不构建本项目
  dontUseCmakeConfigure = true;

  # 忽略 musl libc，因为这是 @swc/core 的可选依赖
  autoPatchelfIgnoreMissingDeps = [
    "libc.musl-x86_64.so.1"
  ];

  # gyp builds need C++17 (docker run in CI passes CXXFLAGS=-std=c++17)
  # oniguruma 捆绑的老 C 代码在 GCC14+ 下 incompatible-pointer-types 变为错误，降级回警告
  env.CFLAGS = "-Wno-error=incompatible-pointer-types -Wno-incompatible-pointer-types";
  env.CXXFLAGS = "-std=c++17 -Wno-error=incompatible-pointer-types -Wno-incompatible-pointer-types";

  buildPhase = ''
    runHook preBuild

    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"
    ROOT="$PWD"

    # ── 依赖解包 ─────────────────────────────
    # node 运行时二进制
    mkdir -p deps/node
    tar xf ${nodeTarball} -C deps/node --strip-components=1

    # node 头文件（node-gyp --nodedir 用，include/node 布局）
    mkdir -p deps/node-headers
    tar xf ${nodeHeaders} -C deps/node-headers --strip-components=1

    # nw 头文件（node 源码树布局，--nodedir 指向 node/ 目录）
    mkdir -p deps/nw-headers
    tar xf ${nwHeaders} -C deps/nw-headers
    # node 16.4.2 的 common.gypi 残留 python2 语法，修复为 py3 兼容
    sed -i 's/print sys\.byteorder/print(sys.byteorder)/' deps/nw-headers/node/common.gypi

    # nwjs 运行时
    mkdir -p nwjs
    tar xf ${nwjsTarball} -C nwjs --strip-components=1

    # 微信开发者工具 Windows 安装包 -> package.nw
    mkdir -p deps/exe
    7z x ${devtoolsExe} -o"deps/exe" "code/package.nw" -y
    mv deps/exe/code/package.nw package.nw
    chmod -R u+rwX package.nw

    # 大小写修复（update-wechat-devtools.sh）
    if [ -f "package.nw/js/common/miniprogram-builder/modules/fullcompiler/app/contactandlaunch/updateContactAndLaunch.js" ]; then
      mv "package.nw/js/common/miniprogram-builder/modules/fullcompiler/app/contactandlaunch/updateContactAndLaunch.js" \
         "package.nw/js/common/miniprogram-builder/modules/fullcompiler/app/contactandlaunch/updatecontactandlaunch.js"
    fi

    # ── 补丁：包名 / CLI / core.wxvpkg ───────
    node tools/fix-package-name.js
    bash tools/fix-cli.sh
    WINE=false bash tools/fix-core.sh

    # ── 重建原生模块（rebuild-node-modules.sh 改编） ──
    # CI 用 nw-gyp（需 python2），这里用 node-gyp + nw 头文件（--nodedir）替代
    pushd package.nw/node_modules
    rm -fr vscode-windows-ca-certs \
           vscode-windows-registry \
           vscode-windows-registry-node \
           windows-process-tree
    find . -name "*.pdb" -delete
    find . -name "*.lib" -delete
    find . -name "*.dll" -delete
    rm -fr "@vscode/ripgrep/bin/"*
    mkdir -p "@vscode/ripgrep/bin"
    tar xf ${ripgrepTarball} -C "@vscode/ripgrep/bin"
    popd

    # node-gyp 工具链（npm ci 离线安装）
    mkdir -p deps/tools
    cp ${./npm/tools}/package.json ${./npm/tools}/package-lock.json deps/tools/
    chmod u+w deps/tools/*
    cp -r ${toolsNpmDeps} "$TMPDIR/tools-cache"
    chmod -R u+w "$TMPDIR/tools-cache"
    npm ci --prefix deps/tools --ignore-scripts --offline --cache "$TMPDIR/tools-cache"
    NODE_GYP="node $ROOT/deps/tools/node_modules/node-gyp/bin/node-gyp.js"

    # 待重编译模块源码（npm ci 离线安装）
    mkdir -p package.nw/node_modules_tmp
    cp ${./npm/native}/package.json ${./npm/native}/package-lock.json package.nw/node_modules_tmp/
    chmod u+w package.nw/node_modules_tmp/*
    cp -r ${nativeNpmDeps} "$TMPDIR/native-cache"
    chmod -R u+w "$TMPDIR/native-cache"
    npm ci --prefix package.nw/node_modules_tmp --ignore-scripts --offline --cache "$TMPDIR/native-cache"

    build_module() {
      # $1 = 模块目录, $2 = --nodedir
      pushd "$1"
      $NODE_GYP configure --nodedir="$2" --arch=x64 --verbose
      $NODE_GYP build -j"$NIX_BUILD_CORES"
      popd
    }

    pushd package.nw/node_modules_tmp/node_modules

    # node 侧模块
    build_module nodegit "$ROOT/deps/node-headers"
    pushd nodegit
    rm -rf .github include src lifecycleScripts vendor utils build/vendor build/Release/.deps
    popd
    build_module extract-file-icon "$ROOT/deps/node-headers"
    build_module native-keymap "$ROOT/deps/node-headers"
    build_module node-pty "$ROOT/deps/node-headers"

    # nwjs 侧模块
    build_module native-watchdog "$ROOT/deps/nw-headers/node"

    # oniguruma: node 用 oniguruma-node，nwjs 用 oniguruma
    # 捆绑的 onig C 库是 C89 代码，GCC15 默认 gnu23 把 `()` 原型当作 (void)，需 -std=gnu89
    cp -fr oniguruma oniguruma-node
    ( CFLAGS="-std=gnu89 $CFLAGS"; build_module oniguruma-node "$ROOT/deps/node-headers" )
    ( CFLAGS="-std=gnu89 $CFLAGS"; build_module oniguruma "$ROOT/deps/nw-headers/node" )

    # @vscode/spdlog: nwjs 用 spdlog18，node 用原目录
    cp -fr "@vscode/spdlog" "@vscode/spdlog18"
    build_module "@vscode/spdlog18" "$ROOT/deps/node-headers"

    ( cd "@vscode" && build_module sqlite3 "$ROOT/deps/node-headers" )

    # 清理编译产物
    find . -name ".deps" | xargs -r rm -rf
    find . -name "obj.target" | xargs -r rm -rf
    find . -name "*.a" -delete
    find . -name "*.lib" -delete
    find . -name "*..mk" -delete

    # .node 回写到 package.nw/node_modules（保持相对路径）
    find . -name "*.node" | while read -r f; do
      cp --parents -f "$f" "$ROOT/package.nw/node_modules/"
    done
    popd
    rm -rf package.nw/node_modules_tmp

    # ── 补丁：hackrequire ────────────────────
    bash tools/fix-menu.sh

    # ── 补丁：fix-other.sh 内联 ──────────────
    # wcc/wcsc 替换为 Linux 版本
    cp ${wccBin} package.nw/node_modules/wcc-exec/wcc
    cp ${wcscBin} package.nw/node_modules/wcc-exec/wcsc
    chmod +x package.nw/node_modules/wcc-exec/wcc package.nw/node_modules/wcc-exec/wcsc
    rm -rf package.nw/node_modules/wcc-exec/wcc.exe package.nw/node_modules/wcc-exec/wcsc.exe

    # 可视化用 wcc/wcsc .node
    rm -rf package.nw/node_modules/wcc/build/Release/wcc.node
    cp ${wccNode} package.nw/node_modules/wcc/build/Release/wcc.node
    rm -rf package.nw/node_modules/wcc/build/Release/wcsc.node
    cp ${wcscNode} package.nw/node_modules/wcc/build/Release/wcsc.node

    # 修复 mock 按钮无反应
    sed -i '1s/^/window.prompt = parent.prompt;\n/' "package.nw/js/ideplugin/devtools/index.js"

    # 修复视频无法播放（libffmpeg）
    rm -rf nwjs/lib/libffmpeg.so
    unzip ${libffmpegZip} -d nwjs/lib

    # Skyline 解析插件修复（float-pigment）
    rm -f package.nw/node_modules/node-float-pigment-css/float-pigment-css-for-nodejs.node \
          package.nw/node_modules/node-float-pigment-css/float-pigment-css-for-nwjs.node
    cp ${floatPigmentNode} package.nw/node_modules/node-float-pigment-css/float-pigment-css-for-nodejs.node
    cp ${floatPigmentNode} package.nw/node_modules/node-float-pigment-css/float-pigment-css-for-nwjs.node

    # websocket 找不到（大小写）
    pushd "package.nw/js/libs/vseditor/extensions/node_modules/ws/lib"
    if [ -f "WebSocket.js" ]; then
      mv "WebSocket.js" "websocket.js"
      mv "Receiver.js" "receiver.js"
      mv "Sender.js" "sender.js"
      mv "Constants.js" "constants.js"
      mv "Validation.js" "validation.js"
    fi
    popd

    # 阻止无限启动服务器
    mv "package.nw/js/core/entrance.js" "package.nw/js/core/entrance.js.bak"
    cat "res/scripts/entrance.js" > "package.nw/js/core/entrance.js"
    cat "package.nw/js/core/entrance.js.bak" >> "package.nw/js/core/entrance.js"
    rm "package.nw/js/core/entrance.js.bak"

    # 修复 iframe 导致的崩溃
    sed -i 's#"use strict";##' "package.nw/js/core/index.js"
    mv "package.nw/js/core/index.js" "package.nw/js/core/index.js.bak"
    cat "res/scripts/core_index.js" > "package.nw/js/core/index.js"
    cat "package.nw/js/core/index.js.bak" >> "package.nw/js/core/index.js"
    rm "package.nw/js/core/index.js.bak"

    # 修复编辑器不能覆盖粘贴
    sed -i 's#if(super(),l.isLinux){let#if(super(),l.isLinux){return;let#' "package.nw/js/libs/vseditor/bundled/editor.bundled.js"

    # ── 补丁：replace-skyline.sh 内联 ────────
    rm -f package.nw/node_modules/sharedMemory/sharedMemory.node
    cp ${sharedMemoryNode} package.nw/node_modules/sharedMemory/sharedMemory.node
    rm -f package.nw/node_modules/skyline-addon/build/skyline.node
    cp ${skylineClientNode} package.nw/node_modules/skyline-addon/build/skyline.node

    mv "package.nw/js/extensions/inject/documentstart/index.js" "package.nw/js/extensions/inject/documentstart/index.js.bak"
    cat "res/scripts/document_start.js" > "package.nw/js/extensions/inject/documentstart/index.js"
    cat "package.nw/js/extensions/inject/documentstart/index.js.bak" >> "package.nw/js/extensions/inject/documentstart/index.js"
    rm "package.nw/js/extensions/inject/documentstart/index.js.bak"

    mv "package.nw/js/extensions/skyline/index.js" "package.nw/js/extensions/skyline/index.js.bak"
    cat "res/scripts/skyline.js" > "package.nw/js/extensions/skyline/index.js"
    cat "package.nw/js/extensions/skyline/index.js.bak" >> "package.nw/js/extensions/skyline/index.js"
    rm "package.nw/js/extensions/skyline/index.js.bak"

    # ── nwjs 组装（build-src.yml Compress Resources） ──
    rm -rf nwjs/node nwjs/node.exe
    cp deps/node/bin/node nwjs/node
    chmod u+w nwjs/node
    ln -s node nwjs/node.exe
    ln -s node nwjs/node-18.exe
    ln -s ../package.nw nwjs/package.nw

    # 构建时间戳（固定值，保证可复现；启动脚本仅用于缓存失效判断）
    echo "${finalAttrs.version}" > package.nw/.build_time

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -d "$out/opt/${finalAttrs.pname}"
    install -d "$out/bin"
    cp -a bin nwjs package.nw tools "$out/opt/${finalAttrs.pname}/"
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
          --prefix LD_LIBRARY_PATH : "$out/opt/${finalAttrs.pname}/nwjs/lib" \
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
