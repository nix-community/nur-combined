{ lib, stdenv, fetchurl, cmake, fcitx5, pkgsStatic, python3, unzip, patchelf, zlib, openssl, snappy, writeShellScript, e2fsprogs, curl, fetchFromGitHub, applyPatches, callPackage }:

let
  # 跟随上游正式合入的 Nix 支持；仅保留云候选短暂等待身份锁的补丁。
  wxc = callPackage ../wxc { };
  upstreamSrc = fetchFromGitHub {
    owner = "zhl-HFUT";
    repo = "vtype-linux";
    rev = "03b011c359a354bd8a790e24ae6e1552ae788359";
    hash = "sha256-s5oCuUin2OovdujD4eXeX1QEOQ+w234ObA9zGx5UxKg=";
  };
  src = applyPatches {
    name = "vtype-linux-source";
    src = upstreamSrc;
    patches = [ ./cloud-latency.patch ];
  };
  python = python3.withPackages (ps: [ ps.cryptography ps.python-snappy ]);
  cloudPython = writeShellScript "wetype-cloud-python" ''
    export PATH="${lib.makeBinPath [ openssl wxc ]}:$PATH"
    export WETYPE_WXC="''${WETYPE_WXC:-${wxc}/bin/wxc}"
    export WETYPE_SNAPPY_LIBRARY="${lib.getLib snappy}/lib/libsnappy.so"
    exec ${python}/bin/python3 "$@"
  '';
  version = "0-unstable-2026-10-16";
  ndk = fetchurl {
    url = "https://dl.google.com/android/repository/android-ndk-r27c-linux.zip";
    hash = "sha256-WcL23JZ0O12vXRYmaEZAsgpr0rHYWxMVa5AzN0G61cw=";
  };
  aospImage = fetchurl {
    url = "https://dl.google.com/android/repository/sys-img/android/arm64-v8a-28_r02.zip";
    hash = "sha256-hoRNLt9rp8fxEmH2vj+zd4jJhc/PO4kkz+n1ehzLwKk=";
  };
  bionic = stdenv.mkDerivation {
    pname = "vtype-linux-bionic";
    version = "android-9";
    inherit src;
    nativeBuildInputs = [ unzip e2fsprogs curl ];
    dontConfigure = true;
    dontFixup = true;
    buildPhase = ''
      runHook preBuild
      WETYPE_AOSP_IMAGE=${aospImage} bash scripts/prepare_bionic.sh "$PWD/sysroot"
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      cp -a sysroot "$out"
      runHook postInstall
    '';
  };
  harness = stdenv.mkDerivation {
    pname = "vtype-linux-harness";
    inherit version src;
    nativeBuildInputs = [ unzip patchelf ];
    dontConfigure = true;
    # 宿主程序面向 Android/bionic，不能用本机的 strip 和 ELF 修复钩子处理。
    dontFixup = true;
    buildPhase = ''
      runHook preBuild
      unzip -q ${ndk} 'android-ndk-r27c/toolchains/llvm/prebuilt/linux-x86_64/*'
      toolchain="$PWD/android-ndk-r27c/toolchains/llvm/prebuilt/linux-x86_64"
      for tool in clang ld.lld; do
        patchelf --set-interpreter ${stdenv.cc.bintools.dynamicLinker} \
          --add-rpath ${lib.makeLibraryPath [ zlib ]} \
          "$(readlink -f "$toolchain/bin/$tool")"
      done
      "$toolchain/bin/clang" --target=aarch64-linux-android28 -O0 -g \
        -o wetype-harness harness/jinterop.c -ldl
      "$toolchain/bin/clang" --target=aarch64-linux-android28 -shared -fPIC -O2 \
        -Wl,-soname,libandroid.so -o libandroid.so shim/libandroid.c
      "$toolchain/bin/clang" --target=aarch64-linux-android28 -shared -fPIC -O2 -Wall \
        -o libwetype-cloud.so cloud/cloud_net.c
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      install -Dm755 wetype-harness "$out/libexec/wetype-harness"
      install -Dm755 libandroid.so "$out/lib/libandroid.so"
      install -Dm755 libwetype-cloud.so "$out/lib/libwetype-cloud.so"
      runHook postInstall
    '';
  };
in
stdenv.mkDerivation {
  pname = "vtype-linux";
  inherit version src;

  nativeBuildInputs = [ cmake ];
  buildInputs = [ fcitx5 ];
  cmakeDir = "../fcitx5-wetype";
  doCheck = true;
  checkPhase = ''
    runHook preCheck
    ctest --output-on-failure
    (cd .. && ${cloudPython} -m unittest discover -s tests -p 'test_*.py')
    (cd .. && ${cloudPython} tests/test_snapshot_transport.py)
    runHook postCheck
  '';

  postPatch = ''
    # 上游的云代理入口使用 /usr/bin/python3；NixOS 使用固定的运行时。
    substituteInPlace fcitx5-wetype/src/wetype.cpp \
      --replace-fail '"/usr/bin/python3"' '"${cloudPython}"' \
      --replace-fail '(eng + "/wetype-harness").c_str()' '"${harness}/libexec/wetype-harness"' \
      --replace-fail '(eng+"/wetype-harness").c_str()' '"${harness}/libexec/wetype-harness"' \
      --replace-fail 'qemu = eng + "/qemu-aarch64-static";' 'qemu = "${pkgsStatic.qemu-user}/bin/qemu-aarch64";' \
      --replace-fail 'qemu = "qemu-aarch64-static";' 'qemu = "${pkgsStatic.qemu-user}/bin/qemu-aarch64";' \
      --replace-fail 'sr : eng + "/sysroot"' 'sr : "${bionic}"'
  '';

  postInstall = ''
    # profile 安装的插件不在 Fcitx 的默认库目录，使用绝对路径注册。
    substituteInPlace "$out/share/fcitx5/addon/wetype.conf" \
      --replace-fail 'Library=libfcitx5-wetype' "Library=$out/lib/fcitx5/libfcitx5-wetype"
    mkdir -p "$out/libexec"
    ln -s ${pkgsStatic.qemu-user}/bin/qemu-aarch64 "$out/libexec/qemu-aarch64-static"
    ln -s ${harness}/libexec/wetype-harness "$out/libexec/wetype-harness"
    ln -s ${harness}/lib/libandroid.so "$out/libexec/libandroid.so"
    ln -s ${harness}/lib/libwetype-cloud.so "$out/libexec/libwetype-cloud.so"
    ln -s ${bionic} "$out/libexec/sysroot"
    install -Dm644 ../src/wetype-ime-demo.sh "$out/share/vtype-linux/wetype-ime-demo.sh"
    cp -r ../cloud "$out/share/vtype-linux/cloud"
    install -Dm644 ../scripts/wetype-cloud.py "$out/share/vtype-linux/wetype-cloud.py"
    install -Dm644 ../cloud/实时云桥接.py "$out/libexec/cloud_proxy.py"
    mkdir -p "$out/share/vtype-linux/scripts"
    for script in fetch_apk.py 17_disable_scan_sig.py 21_fake_appender.py test_bionic_daemon.py; do
      install -m644 "../scripts/$script" "$out/share/vtype-linux/scripts/$script"
    done
    install -m644 ../nix/setup.py "$out/share/vtype-linux/setup.py"
    install -Dm644 ../assets/wetype-ime.png "$out/share/icons/hicolor/256x256/apps/wetype-ime.png"
    mkdir -p "$out/bin"
    ln -s ${wxc}/bin/wxc "$out/bin/wxc"
    cat > "$out/bin/wetype-demo" <<'EOF'
    #!${stdenv.shell}
    export WETYPE_ENGINE_DIR="''${WETYPE_ENGINE_DIR:-$HOME/.local/lib/wetype-ime/arm64}"
    export WETYPE_HARNESS="${harness}/libexec/wetype-harness"
    export QEMU_AARCH64="''${QEMU_AARCH64:-${pkgsStatic.qemu-user}/bin/qemu-aarch64}"
    export WETYPE_SYSROOT="''${WETYPE_SYSROOT:-${bionic}}"
    exec ${stdenv.shell} "@out@/share/vtype-linux/wetype-ime-demo.sh" "$@"
    EOF
    cat > "$out/bin/wetype-cloud" <<'EOF'
    #!${stdenv.shell}
    exec ${cloudPython} "@out@/share/vtype-linux/wetype-cloud.py" "$@"
    EOF
    cat > "$out/bin/wetype-setup" <<'EOF'
    #!${stdenv.shell}
    exec ${cloudPython} "@out@/share/vtype-linux/setup.py" --package "@out@" "$@"
    EOF
    cat > "$out/bin/wetype-check" <<'EOF'
    #!${stdenv.shell}
    exec ${cloudPython} "@out@/share/vtype-linux/scripts/test_bionic_daemon.py" \
      --engine-dir "''${WETYPE_ENGINE_DIR:-$HOME/.local/lib/wetype-ime/arm64}" \
      --harness "@out@/libexec/wetype-harness" --qemu "@out@/libexec/qemu-aarch64-static" "$@"
    EOF
    chmod +x "$out/bin/"wetype-{demo,cloud,setup,check}
    substituteInPlace "$out/bin/wetype-demo" --replace-fail '@out@' "$out"
    substituteInPlace "$out/bin/wetype-cloud" --replace-fail '@out@' "$out"
    substituteInPlace "$out/bin/wetype-setup" --replace-fail '@out@' "$out"
    substituteInPlace "$out/bin/wetype-check" --replace-fail '@out@' "$out"
    mkdir -p "$out/share/applications"
    cat > "$out/share/applications/wetype-ime.desktop" <<EOF
    [Desktop Entry]
    Type=Application
    Name=VType 初始化
    Comment=准备微信拼音引擎和词库
    Exec=$out/bin/wetype-setup
    Icon=wetype-ime
    Terminal=true
    Categories=Utility;
    EOF
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    ${cloudPython} ../nix/check-wxc.py --package "$out" --wxc ${wxc}/bin/wxc
    ${cloudPython} ../nix/check-runtime.py --package "$out"
    runHook postInstallCheck
  '';

  meta = {
    description = "微信拼音 Fcitx5 插件（引擎和词库需另行下载到用户目录）";
    homepage = "https://github.com/zhl-HFUT/vtype-linux";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
  };
}
