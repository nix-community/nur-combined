{
  lib,
  stdenv,
  fetchurl,
  writeShellScript,
  sources,

  cmake,
  patchelf,
  pkg-config,
  python3,
  unzip,

  fcitx5,
  pkgsCross,
  qemu-user,

  source ? sources.wetype-ime-linux,
}:

let
  aarch64 = pkgsCross.aarch64-multiplatform;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "wetype";
  inherit (source) version src;

  __structuedAttrs = true;
  strictDeps = true;

  cmakeDir = "../fcitx5-wetype";

  nativeBuildInputs = [
    cmake
    patchelf
    pkg-config
    python3
    unzip
    aarch64.stdenv.cc
  ];

  buildInputs = [ fcitx5 ];

  env.WETYPE_ZLIB_SO = "${lib.getLib aarch64.zlib}/lib/libz.so.1";

  postPatch = ''
    # Fcitx 5.1.22 headers use C++20 features.
    substituteInPlace fcitx5-wetype/CMakeLists.txt --replace-fail "CMAKE_CXX_STANDARD 17" "CMAKE_CXX_STANDARD 20"
    substituteInPlace scripts/20_build.sh          --replace-fail aarch64-linux-gnu-gcc ${aarch64.stdenv.cc.targetPrefix}cc
    substituteInPlace fcitx5-wetype/src/wetype.cpp --replace-fail '"/usr/lib/wetype-ime/arm64"' "\"$out/lib/wetype-ime/arm64\""
  '';

  postBuild = ''
    pushd ..
    bash scripts/prepare_assets.sh ${finalAttrs.passthru.apk}
    bash scripts/20_build.sh
    bash scripts/10_patch_libs.sh
    popd
  '';

  postInstall = ''
    engineDir="$out/lib/wetype-ime/arm64"
    pushd ..
    install -Dm755 runtime/*.so* -t "$engineDir/lib"
    install -Dm755 harness/jinterop "$engineDir/wetype-harness"
    mkdir -p "$engineDir/dicts"
    cp -r .deps/wechat-ime/assets/config/beta/. "$engineDir/dicts"
    popd
    ln -s ${finalAttrs.passthru.launcher} "$engineDir/qemu-aarch64-static"
  ''
  + lib.optionalString (!stdenv.hostPlatform.isAarch64) ''
    ln -s ${aarch64.glibc} "$engineDir/sysroot"
  '';

  # The WeType libraries carry binary patches at fixed file offsets.
  stripExclude = [ "lib/wetype-ime/*" ];

  passthru = {
    apk = fetchurl {
      url = "https://download.z.weixin.qq.com/app/android/3.5.4/wxkb_1308_32.apk";
      hash = "sha256-e1elqas679MEExZfKYITlhvSAYFatIxq0gXDspUKkPs=";
    };
    # nix-update auto -u
    updateScript = ./update.sh;
    # The addon always launches the engine as `<qemu> -L <sysroot> <harness> ...`;
    launcher =
      if stdenv.hostPlatform.isAarch64 then
        writeShellScript "wetype-native-launcher" ''
          if [ "$1" = -L ]; then shift 2; fi
          exec "$@"
        ''
      else
        lib.getExe' qemu-user "qemu-aarch64";
  };

  meta = {
    description = "Fcitx 5 input method powered by the WeType engine";
    homepage = "https://github.com/yu1745/wetype-ime-linux";
    license = with lib.licenses; [
      gpl3Plus
      unfree
    ];
    maintainers = with lib.maintainers; [ moraxyc ];
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
    sourceProvenance = with lib.sourceTypes; [
      binaryNativeCode
      fromSource
    ];
  };
})
