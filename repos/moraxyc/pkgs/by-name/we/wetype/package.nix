{
  lib,
  stdenv,
  fetchurl,
  writeShellScript,
  sources,

  androidenv,
  cmake,
  curl,
  e2fsprogs,
  patchelf,
  pkg-config,
  python3,
  unzip,

  fcitx5,
  qemu-user,

  source ? sources.wetype-ime-linux,
}:

let
  # scripts/20_build.sh cross-compiles the ARM64 harness and its libandroid.so
  # stand-in for bionic/API 28 with the Android NDK. r27c (27.2.12479018) is the
  # version upstream pins, and the NDK only ships an x86_64-linux host toolchain.
  ndk =
    (androidenv.composeAndroidPackages {
      includeNDK = true;
      ndkVersions = [ "27.2.12479018" ];
      includeEmulator = false;
      includeSystemImages = false;
      includeCmake = false;
    }).ndk-bundle;

  # scripts/prepare_bionic.sh extracts the bionic runtime (linker64, libc, libm,
  # libdl, libz, liblog, libc++) from this AOSP Android 9 arm64 system image.
  # Android 9 is the newest release keeping them directly in /system instead of
  # APEXes, and the engine needs at most LIBC_P symbols. Pinned so builds stay
  # offline; update.sh syncs it with the copy in scripts/prepare_bionic.sh.
  bionicImage = fetchurl {
    url = "https://dl.google.com/android/repository/sys-img/android/arm64-v8a-28_r02.zip";
    hash = "sha256-hoRNLt9rp8fxEmH2vj+zd4jJhc/PO4kkz+n1ehzLwKk=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "wetype";
  inherit (source) version src;

  __structuredAttrs = true;
  strictDeps = true;

  cmakeDir = "../fcitx5-wetype";

  nativeBuildInputs = [
    cmake
    patchelf
    pkg-config
    python3
    unzip
    # prepare_bionic.sh streams the system image out of the zip with unzip/dd,
    # unpacks it with debugfs, and refuses to run without curl on PATH.
    curl
    e2fsprogs
    ndk
  ];

  buildInputs = [ fcitx5 ];

  env = {
    ANDROID_NDK_HOME = "${ndk}/libexec/android-sdk/ndk-bundle";
    WETYPE_AOSP_IMAGE = "${bionicImage}";
  };

  postPatch = ''
    substituteInPlace fcitx5-wetype/src/wetype.cpp --replace-fail '"/usr/lib/wetype-ime/arm64"' "\"$out/lib/wetype-ime/arm64\""
  '';

  # The addon above is native host code; the engine it drives is built by the
  # upstream scripts: fetch the pinned APK, build the ARM64 harness and the
  # bionic sysroot, then patch the engine libraries copied out of that APK.
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
    install -Dm755 -t "$engineDir/lib" runtime/*.so*
    install -Dm755 harness/jinterop "$engineDir/wetype-harness"
    install -dm755 "$engineDir/sysroot"
    cp -r runtime/sysroot/. "$engineDir/sysroot/"
    install -dm755 "$engineDir/dicts"
    cp -r .deps/wechat-ime/assets/config/beta/. "$engineDir/dicts/"
    popd
  ''
  + lib.optionalString (!stdenv.hostPlatform.isAarch64) ''
    # The addon always runs the engine as `<qemu> -L <sysroot> <harness> ...`,
    # so ship the QEMU user binary next to it instead of relying on the host.
    ln -s ${finalAttrs.passthru.launcher} "$engineDir/qemu-aarch64-static"
  ''
  + lib.optionalString stdenv.hostPlatform.isAarch64 ''
    # ARM64 hosts run the harness directly, so point its ELF interpreter at the
    # bundled bionic linker; upstream's install step does the same.
    patchelf --set-interpreter "$engineDir/sysroot/system/bin/linker64" "$engineDir/wetype-harness"
  '';

  # The engine libraries carry binary patches at fixed file offsets.
  stripExclude = [ "lib/wetype-ime/*" ];

  passthru = {
    apk = fetchurl {
      url = "https://download.z.weixin.qq.com/app/android/3.5.4/wxkb_1308_32.apk";
      hash = "sha256-e1elqas679MEExZfKYITlhvSAYFatIxq0gXDspUKkPs=";
    };
    inherit bionicImage;
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
