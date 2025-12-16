{
  sources,
  version,
  srcInfo,
  lib,
  stdenv,
  flutter338,
  makeDesktopItem,
  copyDesktopItems,
  autoPatchelfHook,
  mimalloc,
  mpv-unwrapped,
}:
let
  flutter = flutter338;
in
flutter.buildFlutterApplication {
  inherit (sources) pname src;
  inherit version;
  inherit (srcInfo) pubspecLock;
  inherit (srcInfo) gitHashes;

  # from https://github.com/NixOS/nixpkgs/blob/418468ac9527e799809c900eda37cbff999199b6/pkgs/by-name/on/oneanime/package.nix#L81
  customSourceBuilders = {
    # unofficial media_kit_libs_linux
    media_kit_libs_linux =
      { version, src, ... }:
      stdenv.mkDerivation rec {
        pname = "media_kit_libs_linux";
        inherit version src;
        inherit (src) passthru;

        postPatch = ''
          sed -i '/set(MIMALLOC "mimalloc-/,/add_custom_target/d' libs/linux/media_kit_libs_linux/linux/CMakeLists.txt
          sed -i '/set(PLUGIN_NAME "media_kit_libs_linux_plugin")/i add_custom_target("MIMALLOC_TARGET" ALL DEPENDS ${mimalloc}/lib/mimalloc.o)' libs/linux/media_kit_libs_linux/linux/CMakeLists.txt
        '';

        installPhase = ''
          runHook preInstall

          cp -r . $out

          runHook postInstall
        '';
      };
    # unofficial media_kit_video
    media_kit_video =
      { version, src, ... }:
      stdenv.mkDerivation rec {
        pname = "media_kit_video";
        inherit version src;
        inherit (src) passthru;

        postPatch = ''
          sed -i '/if(ARCH_NAME STREQUAL "x86_64")/,/if(MEDIA_KIT_LIBS_AVAILABLE)/{ /if(MEDIA_KIT_LIBS_AVAILABLE)/!d; /set(LIBMPV_ZIP_URL/d }' media_kit_video/linux/CMakeLists.txt
          sed -i '/if(MEDIA_KIT_LIBS_AVAILABLE)/i \
            set(LIBMPV_UNZIP_DIR "${mpv-unwrapped}/lib")\n\
            set(LIBMPV_PATH "${mpv-unwrapped}/lib")\n\
            set(LIBMPV_HEADER_UNZIP_DIR "${mpv-unwrapped.dev}/include")' media_kit_video/linux/CMakeLists.txt
        '';

        installPhase = ''
          runHook preInstall

          cp -r . $out

          runHook postInstall
        '';
      };
  };

  desktopItems = [
    (makeDesktopItem {
      name = "loveiwara";
      desktopName = "LoveIwara";
      genericName = "Love Iwara";
      exec = "i_iwara %u";
      comment = "Unofficial iwara application";
      terminal = false;
      categories = [
        "AudioVideo"
        "Video"
      ];
      keywords = [
        "Flutter"
        "share"
        "images"
      ];
      icon = "loveiwara";
    })
  ];

  nativeBuildInputs = [
    copyDesktopItems
    autoPatchelfHook
  ];

  # https://github.com/NixOS/nixpkgs/blob/7905606cfa51a1815787377b9cb04291e87ebcb4/pkgs/by-name/fl/fluffychat/package.nix#L120
  postPatch = ''
    substituteInPlace linux/CMakeLists.txt \
      --replace-fail \
      "PRIVATE -Wall -Werror" \
      "PRIVATE -Wall -Werror -Wno-deprecated"
  '';

  postInstall = ''
    ln --symbolic --no-dereference --force ${mpv-unwrapped}/lib/libmpv.so.2 $out/app/loveiwara/lib/libmpv.so.2
    install -D assets/icon/launcher_icon_v2.png $out/share/pixmaps/loveiwara.png
  '';

  meta = {
    description = "Unofficial Iwara app";
    homepage = "https://github.com/FoxSensei001/LoveIwara";
    mainProgram = "i_iwara";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    platforms = lib.platforms.linux;
  };
}
