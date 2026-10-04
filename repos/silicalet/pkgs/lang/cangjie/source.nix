{
  lib,
  callPackage,
  cangjieBuildPkgs,
  fetchgit,
  git,
  gnumake,
  libxcrypt,
  makeWrapper,
  ninja,
  openssl,
  patch,
  python3,
  runCommand,
  stdenv,
}:

let
  version = "1.2.0";
  gccLibDir = "${stdenv.cc.cc}/lib/gcc/${stdenv.hostPlatform.config}/${stdenv.cc.cc.version}";

  setupCangjieLinker = ''
    cangjieToolchain="$TMPDIR/cangjie-toolchain"
    mkdir -p "$cangjieToolchain/bin"
    cat > "$cangjieToolchain/bin/ld" <<'EOF'
    #!${stdenv.shell}
    set -eu

    args=(
      "-L${stdenv.cc.cc.lib}/lib"
      "-L${gccLibDir}"
    )
    replace_dynamic_linker=0
    for arg in "$@"; do
      if [ "$replace_dynamic_linker" = 1 ]; then
        args+=("${stdenv.cc.libc}/lib/ld-linux-x86-64.so.2")
        replace_dynamic_linker=0
        continue
      fi

      case "$arg" in
        -dynamic-linker)
          args+=("$arg")
          replace_dynamic_linker=1
          ;;
        Scrt1.o) args+=("${stdenv.cc.libc}/lib/Scrt1.o") ;;
        crti.o) args+=("${stdenv.cc.libc}/lib/crti.o") ;;
        crtn.o) args+=("${stdenv.cc.libc}/lib/crtn.o") ;;
        crtbeginS.o) args+=("${gccLibDir}/crtbeginS.o") ;;
        crtendS.o) args+=("${gccLibDir}/crtendS.o") ;;
        *) args+=("$arg") ;;
      esac
    done

    exec ${stdenv.cc}/bin/ld "''${args[@]}"
    EOF
    chmod +x "$cangjieToolchain/bin/ld"
  '';

  sources = {
    compiler = fetchgit {
      url = "https://gitcode.com/Cangjie/cangjie_compiler.git";
      rev = "91c24c4fc5ce6d77cb14ff6d63d04dca85e5d803";
      hash = "sha256-HVVjW3KAXePDtedhouLhkEUHIXEWBNuiLNpkLl0T0Cc=";
    };

    runtime = fetchgit {
      url = "https://gitcode.com/Cangjie/cangjie_runtime.git";
      rev = "8a5e36d30bf37fbf98c007fb1cdcf7c6f1aa733c";
      hash = "sha256-+1T+4XzVvpGipJ78joi4+rs1M+FPVrQL38bhJXppl3M=";
    };

    stdx = fetchgit {
      url = "https://gitcode.com/Cangjie/cangjie_stdx.git";
      rev = "486a1a1e251b0bd6f2941551c683823175402aac";
      hash = "sha256-HhTYQ1l7tGyWgp9Mon/NhUWAmv6ouBwhgAQgAXuf0pc=";
    };

    tools = fetchgit {
      url = "https://gitcode.com/Cangjie/cangjie_tools.git";
      rev = "2d2841257a09fc2247515392e1d4bfbfb8891e82";
      hash = "sha256-leO0YwEqIToEIKBQp0siTSbbFs1geT2d1GiHaR7GQmg=";
    };

    flatbuffers = fetchgit {
      url = "https://gitcode.com/openharmony/third_party_flatbuffers.git";
      rev = "c3e4d69cbd5950e43f775ba76eadb30750d6e0b7";
      hash = "sha256-kzNe4XB3IeXZXC0WZzEJ832njiZ0tJsipWNuiO1UA1A=";
    };

    boundscheck = fetchgit {
      url = "https://gitcode.com/openharmony/third_party_bounds_checking_function.git";
      rev = "93cb12caf7eb674ca11126c3fcdbb58ed7fa275e";
      hash = "sha256-MmtvcYH9nIXp0iOE8Meog5+uxwYaBSsR2e4M/BYpnnU=";
    };

    tinytoml = fetchgit {
      url = "https://gitcode.com/src-openeuler/tinytoml.git";
      rev = "c2cb1be509d571e581fdb95bbc7afdf341791c21";
      hash = "sha256-6UL75iddNurGuacBWEpfbPWUAAr+HMeV+D91HTVz+1k=";
    };

    llvm = fetchgit {
      url = "https://gitcode.com/Cangjie/llvm-project.git";
      rev = "1efd687e2c7d282b7097f64ccf228746ac3d82e6";
      hash = "sha256-FKN9GKYhmhEzinrzwFHnkh6wVKoO7GCGGNCsSh1cnUo=";
      leaveDotGit = true;
    };

    pcre2 = fetchgit {
      url = "https://gitcode.com/openharmony/third_party_pcre2.git";
      rev = "f0eb89f421f1da45f498d136b627b4b809db4802";
      hash = "sha256-hQd4ylVFCNQERZ+xDPk8SUxi68oXF0N6VW3ALYPuwoE=";
    };

    libuv = fetchgit {
      url = "https://gitcode.com/libuv/libuv.git";
      rev = "e9f29cb984231524e3931aa0ae2c5dae1a32884e";
      hash = "sha256-U68BmIQNpmIy3prS7LkYl+wvDJQNikoeFiKh50yQFoA=";
    };

    zlib = fetchgit {
      url = "https://gitcode.com/openharmony/third_party_zlib.git";
      rev = "9a1de89f7c80f8fc811527dd57135b8b4c00a2e8";
      hash = "sha256-wt3iXDb/Dq+KbMjeCYMYuDOtG6iKEDiWsekN99FvyDo=";
    };
  };

  cangjieCompiler = stdenv.mkDerivation {
    pname = "cangjie-compiler";
    inherit version;

    src = sources.compiler;

    nativeBuildInputs = [
      cangjieBuildPkgs.llvmPackages_15.clang
      cangjieBuildPkgs.cmake
      git
      ninja
      patch
      python3
    ];

    buildInputs = [
      libxcrypt
      openssl
    ];

    postUnpack = ''
      chmod -R u+w "$sourceRoot"
      cp -R ${sources.flatbuffers} "$sourceRoot/third_party/flatbuffers"
      cp -R ${sources.boundscheck} "$sourceRoot/third_party/boundscheck"
      cp -R ${sources.tinytoml} "$sourceRoot/third_party/tinytoml"
      cp -R ${sources.llvm} "$sourceRoot/third_party/llvm-project"
      chmod -R u+w "$sourceRoot/third_party"
    '';

    dontUseCmakeConfigure = true;

    buildPhase = ''
      runHook preBuild

      python3 build.py build \
        --build-type release \
        --version ${version} \
        --no-tests \
        --jobs "$NIX_BUILD_CORES"

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      python3 build.py install
      mkdir -p "$out"
      cp -R output/. "$out/"

      runHook postInstall
    '';

    meta = {
      description = "Cangjie compiler built from source";
      homepage = "https://gitcode.com/Cangjie/cangjie_compiler";
      license = lib.licenses.asl20;
      platforms = lib.platforms.linux;
    };
  };

  cangjieRuntime = stdenv.mkDerivation {
    pname = "cangjie-runtime";
    inherit version;

    src = sources.runtime;

    nativeBuildInputs = [
      cangjieBuildPkgs.llvmPackages_15.clang
      cangjieBuildPkgs.cmake
      git
      gnumake
      python3
    ];

    postUnpack = ''
      chmod -R u+w "$sourceRoot"
      cp -R ${sources.boundscheck} \
        "$sourceRoot/runtime/third_party/third_party_bounds_checking_function"
      chmod -R u+w "$sourceRoot/runtime/third_party"
    '';

    dontUseCmakeConfigure = true;

    buildPhase = ''
      runHook preBuild

      pushd runtime
      python3 build.py build \
        --build-type release \
        --version ${version}
      popd

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out"
      cp -R runtime/output/common/linux_release_x86_64/. "$out/"
      pushd runtime
      python3 build.py install --prefix "$out"
      popd

      runHook postInstall
    '';

    meta = cangjieCompiler.meta // {
      description = "Cangjie runtime built from source";
    };
  };

  cangjieCore = runCommand "cangjie-core-${version}" { } ''
    mkdir -p "$out"
    cp -R ${cangjieCompiler}/. "$out/"
    chmod -R u+w "$out"
    cp -R ${cangjieRuntime}/. "$out/"
  '';

  cangjieStdlib = stdenv.mkDerivation {
    pname = "cangjie-stdlib";
    inherit version;

    src = sources.runtime;

    nativeBuildInputs = [
      cangjieBuildPkgs.llvmPackages_15.clang
      cangjieBuildPkgs.cmake
      ninja
      python3
    ];

    buildInputs = [ openssl ];

    postUnpack = ''
      chmod -R u+w "$sourceRoot"
      cp -R ${sources.flatbuffers} "$sourceRoot/stdlib/third_party/flatbuffers"
      cp -R ${sources.pcre2} "$sourceRoot/stdlib/third_party/pcre2"
      cp -R ${sources.boundscheck} "$sourceRoot/stdlib/third_party/boundscheck-v1.1.16"
      chmod -R u+w "$sourceRoot/stdlib/third_party"
    '';

    dontUseCmakeConfigure = true;

    buildPhase = ''
      runHook preBuild

      export CANGJIE_HOME="$TMPDIR/cangjie-home"
      mkdir -p "$CANGJIE_HOME"
      cp -R ${cangjieCore}/. "$CANGJIE_HOME/"
      chmod -R u+w "$CANGJIE_HOME"
      export PATH="$CANGJIE_HOME/bin:$CANGJIE_HOME/tools/bin:$CANGJIE_HOME/third_party/llvm/bin:$PATH"
      export LD_LIBRARY_PATH="$CANGJIE_HOME/runtime/lib/linux_x86_64_cjnative:$CANGJIE_HOME/tools/lib:${openssl.out}/lib"

      pushd stdlib
      python3 build.py build \
        --build-type release \
        --jobs "$NIX_BUILD_CORES" \
        --target-lib="$CANGJIE_HOME/runtime/lib/linux_x86_64_cjnative" \
        --target-lib="${openssl.out}/lib"
      popd

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      pushd stdlib
      python3 build.py install --prefix "$out"
      popd

      runHook postInstall
    '';

    meta = cangjieCompiler.meta // {
      description = "Cangjie standard library built from source";
    };
  };

  cangjieSdk = runCommand "cangjie-sdk-${version}" { } ''
    mkdir -p "$out"
    cp -R ${cangjieCore}/. "$out/"
    chmod -R u+w "$out"
    cp -R ${cangjieStdlib}/. "$out/"
  '';

  cangjieStdx = stdenv.mkDerivation {
    pname = "cangjie-stdx";
    inherit version;

    src = sources.stdx;

    nativeBuildInputs = [
      cangjieBuildPkgs.llvmPackages_15.clang
      cangjieBuildPkgs.cmake
      ninja
      python3
    ];

    buildInputs = [ openssl ];

    postUnpack = ''
      chmod -R u+w "$sourceRoot"
      mkdir -p cangjie_compiler/schema
      cp -R ${sources.compiler}/schema/. cangjie_compiler/schema/
      cp -R ${sources.flatbuffers} "$sourceRoot/third_party/flatbuffers"
      cp -R ${sources.boundscheck} "$sourceRoot/third_party/boundscheck-v1.1.16"
      cp -R ${sources.zlib} "$sourceRoot/third_party/zlib"
      chmod -R u+w "$sourceRoot/third_party"
    '';

    dontUseCmakeConfigure = true;

    buildPhase = ''
      runHook preBuild

      export CANGJIE_HOME="$TMPDIR/cangjie-home"
      mkdir -p "$CANGJIE_HOME"
      cp -R ${cangjieSdk}/. "$CANGJIE_HOME/"
      chmod -R u+w "$CANGJIE_HOME"
      ${setupCangjieLinker}
      export PATH="$cangjieToolchain/bin:$CANGJIE_HOME/bin:$CANGJIE_HOME/tools/bin:$CANGJIE_HOME/third_party/llvm/bin:$PATH"
      export LD_LIBRARY_PATH="$CANGJIE_HOME/runtime/lib/linux_x86_64_cjnative:$CANGJIE_HOME/tools/lib:${openssl.out}/lib"

      python3 build.py build \
        --build-type release \
        --jobs "$NIX_BUILD_CORES" \
        --include="$CANGJIE_HOME/include" \
        --target-lib="${openssl.out}/lib"

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      python3 build.py install --prefix "$out"

      runHook postInstall
    '';

    meta = cangjieCompiler.meta // {
      description = "Cangjie extension libraries built from source";
    };
  };

  cangjieCjpm = stdenv.mkDerivation {
    pname = "cangjie-cjpm";
    inherit version;

    src = sources.tools;

    nativeBuildInputs = [
      cangjieBuildPkgs.llvmPackages_15.clang
      cangjieBuildPkgs.cmake
      gnumake
      python3
    ];

    postUnpack = ''
      chmod -R u+w "$sourceRoot"
      mkdir -p "$sourceRoot/cjpm/cpp/third_party/libuv"
      cp -R ${sources.libuv}/. "$sourceRoot/cjpm/cpp/third_party/libuv/"
      chmod -R u+w "$sourceRoot/cjpm/cpp/third_party"
    '';

    dontUseCmakeConfigure = true;

    buildPhase = ''
      runHook preBuild

      export CANGJIE_HOME="$TMPDIR/cangjie-home"
      mkdir -p "$CANGJIE_HOME"
      cp -R ${cangjieSdk}/. "$CANGJIE_HOME/"
      chmod -R u+w "$CANGJIE_HOME"
      export CANGJIE_STDX_PATH="${cangjieStdx}/linux_x86_64_cjnative/static/stdx"
      ${setupCangjieLinker}
      export PATH="$cangjieToolchain/bin:$CANGJIE_HOME/bin:$CANGJIE_HOME/tools/bin:$CANGJIE_HOME/third_party/llvm/bin:$PATH"
      export LD_LIBRARY_PATH="$CANGJIE_HOME/runtime/lib/linux_x86_64_cjnative:$CANGJIE_HOME/tools/lib:${openssl.out}/lib"

      pushd cjpm/build
      python3 build.py build -t release --target native
      popd
      test -x cjpm/dist/cjpm

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/bin" "$out/share/cangjie"
      cp cjpm/dist/cjpm "$out/bin/"
      cp cjpm/dist/cangjie-repo.toml "$out/share/cangjie/"

      runHook postInstall
    '';

    meta = cangjieCompiler.meta // {
      description = "Cangjie package manager built from source";
      mainProgram = "cjpm";
    };
  };

  cangjieCjfmt = stdenv.mkDerivation {
    pname = "cangjie-cjfmt";
    inherit version;

    src = sources.tools;

    nativeBuildInputs = [
      cangjieBuildPkgs.llvmPackages_15.clang
      cangjieBuildPkgs.cmake
      ninja
      python3
    ];

    dontUseCmakeConfigure = true;

    buildPhase = ''
      runHook preBuild

      export CANGJIE_HOME="$TMPDIR/cangjie-home"
      mkdir -p "$CANGJIE_HOME"
      cp -R ${cangjieSdk}/. "$CANGJIE_HOME/"
      chmod -R u+w "$CANGJIE_HOME"
      export LD_LIBRARY_PATH="$CANGJIE_HOME/tools/lib"

      pushd cjfmt/build
      python3 build.py build -t release -j "$NIX_BUILD_CORES"
      popd

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      pushd cjfmt/build
      python3 build.py install --prefix "$out"
      popd

      runHook postInstall
    '';

    meta = cangjieCompiler.meta // {
      description = "Cangjie formatter built from source";
      mainProgram = "cjfmt";
    };
  };
in
stdenv.mkDerivation {
  pname = "cangjie";
  inherit version;

  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    sdk="$out/share/cangjie"
    toolchain="$out/libexec/cangjie-toolchain"
    mkdir -p "$sdk" "$sdk/stdlib" "$sdk/tools/bin" "$sdk/tools/config" "$out/bin" "$toolchain/bin"
    cp -R ${cangjieSdk}/. "$sdk/"
    cp -R ${cangjieStdx}/. "$sdk/stdlib/"
    cp ${cangjieCjpm}/bin/cjpm "$sdk/tools/bin/"
    cp ${cangjieCjpm}/share/cangjie/cangjie-repo.toml "$sdk/tools/"
    cp ${cangjieCjfmt}/bin/cjfmt "$sdk/tools/bin/"
    cp -R ${cangjieCjfmt}/config/. "$sdk/tools/config/"
    cp "$sdk/tools/config/cangjie-format.toml" "$sdk/"

    cat > "$toolchain/bin/ld" <<'EOF'
    #!${stdenv.shell}
    set -eu

    args=(
      "-L${stdenv.cc.cc.lib}/lib"
      "-L${gccLibDir}"
    )
    replace_dynamic_linker=0
    for arg in "$@"; do
      if [ "$replace_dynamic_linker" = 1 ]; then
        args+=("${stdenv.cc.libc}/lib/ld-linux-x86-64.so.2")
        replace_dynamic_linker=0
        continue
      fi

      case "$arg" in
        -dynamic-linker)
          args+=("$arg")
          replace_dynamic_linker=1
          ;;
        Scrt1.o) args+=("${stdenv.cc.libc}/lib/Scrt1.o") ;;
        crti.o) args+=("${stdenv.cc.libc}/lib/crti.o") ;;
        crtn.o) args+=("${stdenv.cc.libc}/lib/crtn.o") ;;
        crtbeginS.o) args+=("${gccLibDir}/crtbeginS.o") ;;
        crtendS.o) args+=("${gccLibDir}/crtendS.o") ;;
        *) args+=("$arg") ;;
      esac
    done

    exec ${stdenv.cc}/bin/ld "''${args[@]}"
    EOF
    chmod +x "$toolchain/bin/ld"

    sdkLibraryPath="$sdk/lib:$sdk/lib/linux_x86_64_cjnative:$sdk/modules/linux_x86_64_cjnative:$sdk/runtime/lib/linux_x86_64_cjnative:$sdk/tools/lib:$sdk/stdlib/linux_x86_64_cjnative/dynamic/stdx"
    runtimeLibraryPath="${lib.makeLibraryPath [ openssl stdenv.cc.cc.lib ]}:$sdkLibraryPath"
    sdkPath="$toolchain/bin:$sdk/bin:$sdk/tools/bin:$sdk/third_party/llvm/bin:${lib.makeBinPath [ stdenv.cc stdenv.cc.bintools ]}"

    for tool in "$sdk"/bin/* "$sdk"/tools/bin/*; do
      if [ -f "$tool" ] && [ -x "$tool" ]; then
        toolName="$(basename "$tool")"
        wrapperArgs=(
          --set CANGJIE_HOME "$sdk"
          --set CANGJIE_STDX_PATH "$sdk/stdlib/linux_x86_64_cjnative/static/stdx"
          --prefix PATH : "$sdkPath"
          --prefix LD_LIBRARY_PATH : "$runtimeLibraryPath"
        )

        if [ "$toolName" = cjc ]; then
          wrapperArgs+=(--add-flags --set-runtime-rpath)
        fi

        makeWrapper "$tool" "$out/bin/$toolName" "''${wrapperArgs[@]}"
      fi
    done
  '';

  passthru = {
    inherit
      cangjieCompiler
      cangjieCore
      cangjieCjfmt
      cangjieCjpm
      cangjieRuntime
      cangjieSdk
      cangjieStdlib
      cangjieStdx
      sources
      ;
    binary = callPackage ./binary.nix { };
  };

  meta = cangjieCompiler.meta // {
    description = "Cangjie SDK built from source";
    mainProgram = "cjc";
  };
}
