{
  sources,
  stdenv,
  makeWrapper,
  lib,
  electron_11,
  makeDesktopItem,
  copyDesktopItems,
  dpkg,
  # BaiduNetdisk dependencies
  libappindicator,
  libdbusmenu,
  libgbm,
  libglvnd,
}:
################################################################################
# Mostly based on baidnetdisk-electron package from AUR:
# https://aur.archlinux.org/packages/baidunetdisk-electron
################################################################################
let
  libraries = [
    stdenv.cc.cc.lib
    libappindicator
    libdbusmenu
    libgbm
    libglvnd
  ];

  dist = stdenv.mkDerivation (finalAttrs: {
    inherit (sources.baidunetdisk) pname version src;

    dontFixup = true;

    nativeBuildInputs = [ dpkg ];

    unpackPhase = ''
      dpkg -x $src .
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp -r opt/baidunetdisk/* $out

      pushd $out
      rm -rf \
        baidunetdisk \
        baidunetdisk.desktop \
        baiduNetdiskContext.conf \
        baidunetdiskv.desktop \
        bin \
        binswiftshader \
        chrome_100_percent.pak \
        chrome_200_percent.pak \
        chrome-sandbox \
        icudtl.dat \
        libEGL.so \
        libffmpeg.so \
        libGLESv2.so \
        libvk_swiftshader.so \
        libvulkan.so \
        LICENSE.* \
        locales \
        resources.pak \
        resources/8bb88996964c4e3202fecaaa5605af03 \
        resources/default.db \
        resources/dir.icns \
        resources/resource.db \
        snapshot_blob.bin \
        v8_context_snapshot.bin \
        vk_swiftshader_icd.json
      popd
    '';
  });
in
stdenv.mkDerivation (finalAttrs: {
  inherit (sources.baidunetdisk) pname version;
  dontUnpack = true;

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];
  postInstall = ''
    mkdir -p $out/bin
    makeWrapper ${electron_11}/bin/electron $out/bin/baidunetdisk \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath libraries}:${dist}" \
      --add-flags "--no-sandbox" \
      --add-flags "${dist}/resources/app.asar"

    install -Dm644 ${dist}/baidunetdisk.svg $out/share/icons/hicolor/scalable/apps/baidunetdisk.svg
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "baidunetdisk";
      desktopName = "Baidu Netdisk";
      exec = "baidunetdisk %U";
      terminal = false;
      icon = "baidunetdisk";
      startupWMClass = "baidunetdisk";
      comment = "Baidu Netdisk";
      mimeTypes = [ "x-scheme-handler/baiduyunguanjia" ];
      categories = [ "Network" ];
      extraConfig = {
        "Name[zh_CN]" = "百度网盘";
        "Name[zh_TW]" = "百度網盤";
        "Comment[zh_CN]" = "百度网盘";
        "Comment[zh_TW]" = "百度網盤";
      };
    })
  ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Baidu Netdisk";
    homepage = "https://pan.baidu.com/";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.unfreeRedistributable;
    mainProgram = "baidunetdisk";
  };
})
