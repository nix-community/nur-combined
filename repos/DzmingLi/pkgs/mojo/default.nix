## Mojo 完整工具链：编译器 / LLDB / LSP / mblack 格式化器。
## 单独只装 lsp 不可行——mojo-lsp-server 共享 libMojoLLDB / libKGENCompilerRTShared
## 等同一套库，且要 modular.cfg 指路。
## 基础 derivation 改自 https://github.com/overby-me/overby-me/blob/main/nix/pkgs/mojo.nix
## （论坛贴 https://forum.modular.com/t/mojo-in-nix-full-package-with-lsp-support/548）。
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  fixDarwinDylibNames,
  unzip,
  zstd,
  libedit,
  zlib,
  curl,
  libbsd,
  python3,
  darwin ? null,
}:

let
  inherit (stdenv) isDarwin isLinux;

  condaPlatform = if isDarwin then "osx-arm64" else "linux-64";

  ## 同一版本，linux/darwin 的 mojo-compiler 与 mojo 是各自独立 conda 包，
  ## sha256 不同；mblack 与 ncurses 是 noarch / 跨平台共用。
  sourceHashes = {
    "x86_64-linux" = {
      compiler = "sha256-5T8w1ypl5rCmd0XmmI+XjY9uzBRTFCBjHJcZ65x7nCs=";
      runtime  = "sha256-TXBHRmwT2SscjrGcbSA6hQOvvSsa1j61KJqPS79NKUU=";
    };
    "aarch64-darwin" = {
      compiler = "sha256-6Cy3zhp1aHaiM9Nk1Tl63KWtfiD/9SBMHH6Trv5FSbU=";
      runtime  = "sha256-41uNNFZLMBicWphZkEZrQoP54diXuvI/6d28vJKDRZw=";
    };
  };
  hashes = sourceHashes.${stdenv.hostPlatform.system}
    or (throw "mojo: unsupported system ${stdenv.hostPlatform.system}");

  mblackPythonEnv = python3.withPackages (ps: with ps; [
    click
    mypy-extensions
    packaging
    pathspec
    platformdirs
    tomli
    typing-extensions
  ]);
in
stdenv.mkDerivation rec {
  pname = "mojo";
  version = "26.2.0";

  srcs = [
    (fetchurl {
      url = "https://conda.modular.com/max/${condaPlatform}/mojo-compiler-0.${version}-release.conda";
      sha256 = hashes.compiler;
    })
    (fetchurl {
      url = "https://conda.modular.com/max/${condaPlatform}/mojo-0.${version}-release.conda";
      sha256 = hashes.runtime;
    })
    (fetchurl {
      url = "https://repo.prefix.dev/max/noarch/mblack-${version}-release.conda";
      sha256 = "sha256-PC/OuJzvyomdzXyPJqYgKsrLKgc+TLLvNlUUpGXQHc0=";
    })
  ] ++ lib.optionals isLinux [
    ## nixpkgs 的 ncurses 跟 mojo 自带的 lldb 库 ABI 不匹配
    ## （`NCURSES6_5.0.19991023' not found），改用 conda-forge 同源 ncurses；
    ## darwin 用系统 ncurses，不需要这步。
    (fetchurl {
      url = "https://conda.anaconda.org/conda-forge/linux-64/ncurses-6.5-h2d0b736_3.conda";
      sha256 = "sha256-P94pMjL6P8qYY14RZ95rfH/ag8ryS51skeye77T01YY=";
    })
  ];

  sourceRoot = ".";
  preferLocalBuild = true;

  nativeBuildInputs = [
    unzip
    zstd
  ] ++ lib.optionals isLinux [
    autoPatchelfHook
  ] ++ lib.optionals isDarwin [
    fixDarwinDylibNames
  ];

  buildInputs = lib.optionals isLinux [
    stdenv.cc.cc.lib
    libedit
    zlib
    curl
    libbsd
  ] ++ lib.optionals isDarwin (
    ## darwin.apple_sdk.frameworks.* 在新 nixpkgs (25.11+) 上已废弃，
    ## 但旧 channel 还在；用 `darwin or null` 接，避不到再说。
    if darwin != null && darwin ? apple_sdk
    then with darwin.apple_sdk.frameworks; [ CoreFoundation CoreServices Security ]
    else []
  );

  unpackPhase = ''
    for src in $srcs; do
      unzip -o $src
      tar --zstd -xf pkg-*.tar.zst
      rm pkg-*.tar.zst
    done
  '';

  installPhase = let
    ## Linux 与 darwin 的 modular.cfg 用不同动态库后缀和不同模块清单。
    linuxModularCfg = ''
      [max]
      cache_dir = $out/share/max/.max_cache
      driver_lib = $out/lib/libDeviceDriver.so
      enable_compile_progress = true
      enable_model_ir_cache = true
      engine_lib = $out/lib/libmodular-framework-common.so
      graph_lib = $out/lib/libmof.so
      name = MAX Platform
      path = $out
      serve_lib = $out/lib/libServeRTCAPI.so
      torch_ext_lib = $out/lib/libmodular-framework-torch-ext.so
      version = ${version}

      [mojo-max]
      compilerrt_path = $out/lib/libKGENCompilerRTShared.so
      mgprt_path = $out/lib/libMGPRT.so
      atenrt_path = $out/lib/libATenRT.so
      shared_libs = $out/lib/libAsyncRTMojoBindings.so,$out/lib/libAsyncRTRuntimeGlobals.so,$out/lib/libMSupportGlobals.so,-Xlinker,-rpath,-Xlinker,$out/lib
      driver_path = $out/bin/mojo
      import_path = $out/lib/mojo
      jupyter_path = $out/lib/libMojoJupyter.so
      lldb_path = $out/bin/mojo-lldb
      lldb_plugin_path = $out/lib/libMojoLLDB.so
      lldb_visualizers_path = $out/lib/lldb-visualizers
      lldb_vscode_path = $out/bin/mojo-lldb-dap
      lsp_server_path = $out/bin/mojo-lsp-server
      mblack_path = $out/bin/mblack
      orcrt_path = $out/lib/liborc_rt.a
      repl_entry_point = $out/lib/mojo-repl-entry-point
      system_libs = -lrt,-ldl,-lpthread,-lm,-lz,-ltinfo
      test_executor_path = $out/lib/mojo-test-executor
    '';

    darwinModularCfg = ''
      [max]
      cache_dir = $out/share/max/.max_cache
      enable_model_ir_cache = true
      name = MAX Platform
      path = $out
      version = ${version}

      [mojo-max]
      compilerrt_path = $out/lib/libKGENCompilerRTShared.dylib
      mgprt_path = $out/lib/libMGPRT.dylib
      shared_libs = $out/lib/libAsyncRTMojoBindings.dylib,-Xlinker,-rpath,-Xlinker,$out/lib
      driver_path = $out/bin/mojo
      import_path = $out/lib/mojo
      jupyter_path = $out/lib/libMojoJupyter.dylib
      lldb_path = $out/bin/mojo-lldb
      lldb_plugin_path = $out/lib/libMojoLLDB.dylib
      lldb_visualizers_path = $out/lib/lldb-visualizers
      lldb_vscode_path = $out/bin/mojo-lldb-dap
      lsp_server_path = $out/bin/mojo-lsp-server
      mblack_path = $out/bin/mblack
      repl_entry_point = $out/lib/mojo-repl-entry-point
      lld_path = $out/bin/lld
    '';

    modularCfg = if isDarwin then darwinModularCfg else linuxModularCfg;
  in ''
    mkdir -p $out
    cp -r lib/ $out/lib/
    cp -r bin/ $out/bin/
    cp -r share/ $out/share

    ## mblack 是 python 包，包一层 shell 启动器吊到我们的 python 环境。
    siteDir=$out/lib/${mblackPythonEnv.python.libPrefix}/site-packages
    mkdir -p $siteDir
    cp -r site-packages/* $siteDir/
    cat > $out/bin/mblack << EOF
    #!${stdenv.shell}
    export PYTHONPATH=$siteDir:\$PYTHONPATH
    exec ${mblackPythonEnv}/bin/python -m mblack "\$@"
    EOF
    chmod +x $out/bin/mblack

    ${lib.optionalString isLinux ''
      ## mojo lldb 链了 libedit.so.2，nixpkgs 只有 libedit.so.0。
      ln -s ${libedit}/lib/libedit.so.0 $out/lib/libedit.so.2
    ''}

    ${lib.optionalString isDarwin ''
      ## darwin 二进制和 dylib 里嵌的是 conda-prefix rpath（构建机的路径），
      ## 全部清掉换成 $out/lib，并把对 conda dylib 的引用重写为 store 路径。
      for dylib in $out/lib/*.dylib; do
        install_name_tool -id "$dylib" "$dylib" 2>/dev/null || true
      done

      for f in $out/bin/* $out/lib/*.dylib; do
        [ -f "$f" ] || continue
        for rpath in $(otool -l "$f" 2>/dev/null | grep -A2 LC_RPATH | grep 'path ' | awk '{print $2}'); do
          install_name_tool -delete_rpath "$rpath" "$f" 2>/dev/null || true
        done
        install_name_tool -add_rpath "$out/lib" "$f" 2>/dev/null || true
      done

      for f in $out/bin/* $out/lib/*.dylib; do
        [ -f "$f" ] || continue
        for dep in $(otool -L "$f" 2>/dev/null | tail -n +2 | awk '{print $1}' | grep -v '^/usr/lib\|^/System\|^@'); do
          base=$(basename "$dep")
          if [ -f "$out/lib/$base" ]; then
            install_name_tool -change "$dep" "$out/lib/$base" "$f" 2>/dev/null || true
          fi
        done
      done
    ''}

    ## modular.cfg 里所有路径都得是绝对路径——mojo 启动时按这个找运行时。
    mkdir -p $out/etc/modular
    cat > $out/etc/modular/modular.cfg << EOF
    ${modularCfg}
    EOF

    ## 三个对外二进制都包一层注入 MODULAR_HOME，
    ## 否则用户 shell 没设这变量，mojo 找不到自己的运行时配置。
    for prog in mojo mojo-lldb mojo-lsp-server; do
      mv $out/bin/$prog $out/bin/$prog-unwrapped
    done

    cat > $out/bin/mojo << EOF
    #!${stdenv.shell}
    export MODULAR_HOME=$out/etc/modular
    ${lib.optionalString isLinux "export TERMINFO_DIRS=$out/share/terminfo"}
    exec $out/bin/mojo-unwrapped "\$@"
    EOF

    cat > $out/bin/mojo-lldb << EOF
    #!${stdenv.shell}
    export MODULAR_HOME=$out/etc/modular
    ${lib.optionalString isLinux "export TERMINFO_DIRS=$out/share/terminfo"}
    exec $out/bin/mojo-lldb-unwrapped "\$@"
    EOF

    ## -I $out/lib/mojo 让 lsp 默认能找到 stdlib，否则 import 全标红。
    cat > $out/bin/mojo-lsp-server << EOF
    #!${stdenv.shell}
    export MODULAR_HOME=$out/etc/modular
    exec $out/bin/mojo-lsp-server-unwrapped -I $out/lib/mojo "\$@"
    EOF

    chmod +x $out/bin/mojo $out/bin/mojo-lldb $out/bin/mojo-lsp-server

    ## crashdb / cache 是 mojo 运行时要写的目录，store 只读——软链到 /tmp。
    ln -s /tmp/ $out/etc/modular/crashdb
    ln -s /tmp/ $out/etc/modular/cache
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/mojo --version
    $out/bin/mojo-lldb --version
    $out/bin/mojo-lsp-server --version
  '';

  meta = with lib; {
    description = "Mojo programming language compiler, LSP, and tooling";
    homepage = "https://www.modular.com/mojo";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" "aarch64-darwin" ];
    mainProgram = "mojo";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
