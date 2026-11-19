{
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  vulkan-loader,
  makeWrapper,
  stdenvNoCC,
  fetchzip,
  stdenv,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  src = fetchzip (lib.helper.getSingle ver);
  inherit (ver) version;
in
  stdenvNoCC.mkDerivation rec {
    pname = "vboycolor";

    inherit version src;

    nativeBuildInputs = [
      autoPatchelfHook
      copyDesktopItems
      makeWrapper
    ];

    buildInputs = [
      stdenv.cc.cc.lib
      vulkan-loader
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/${pname} $out/bin
      cp -r . $out/share/${pname}/

      makeWrapper $out/share/${pname}/VBoyColor $out/bin/${pname} \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}"

      install -Dm644 icon.png $out/share/icons/hicolor/64x64/apps/${pname}.png

      runHook postInstall
    '';

    desktopItems = [
      (makeDesktopItem {
        name = pname;
        desktopName = "VBoyColor";
        exec = "${pname} %U";
        comment = meta.description;
        icon = pname;
        startupWMClass = "VBoyColor";
        keywords = [
          "virtual-boy"
          "emulator"
          "nintendo"
        ];
        categories = [
          "Game"
          "Emulator"
        ];
      })
    ];

    meta = {
      description = "Free, open-source Virtual Boy emulator that plays games in color and 3D";
      homepage = "https://github.com/yuk27/VBoyColor";
      license = lib.licenses.gpl3Only;
      maintainers = with lib.maintainers; [Prinky];
      platforms = ["x86_64-linux"];
      mainProgram = pname;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
