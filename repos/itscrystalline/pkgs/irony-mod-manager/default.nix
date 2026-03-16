{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  libgcc,
  zlib,
  fontconfig,
  lttng-ust_2_12,
  icu,
  makeWrapper,
  openssl,
  libX11,
  libICE,
  libSM,
  makeDesktopItem,
  copyDesktopItems,
}: let
  runtimeLibs = [
    icu
    openssl
    libX11
    libICE
    libSM
  ];
in
  stdenv.mkDerivation rec {
    pname = "irony-mod-manager";
    version = "1.27.158";

    src = fetchzip {
      url = "https://github.com/bcssov/IronyModManager/releases/download/v${version}/linux-x64.zip";
      sha256 = "sha256-DZRLN3UneZkt9GzudHMOocrqyD2EqVbh81hht0LWZFY=";
      stripRoot = false;
    };

    nativeBuildInputs = [
      autoPatchelfHook
      makeWrapper
      copyDesktopItems
    ];

    buildInputs = [
      libgcc.lib
      zlib
      fontconfig.lib
      lttng-ust_2_12
    ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out $out/bin
      cp -r $src/* $out/
      mv $out/IronyModManager $out/.IronyModManager-wrapped
      chmod +x $out/.IronyModManager-wrapped
      makeWrapper $out/.IronyModManager-wrapped $out/bin/IronyModManager \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}"
      runHook postInstall
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "Irony Mod Manager";
        exec = "IronyModManager";
        # icon = "yamagi-quake2";
        desktopName = "Irony Mod Manager";
        comment = "Mod Manager for Paradox Games";
        categories = [
          "Game"
        ];
      })
    ];

    meta = with lib; {
      changelog = "https://github.com/bcssov/IronyModManager/releases/tag/v${version}";
      description = "Mod Manager for Paradox Games";
      homepage = "https://github.com/bcssov/IronyModManager";
      maintainers = [];
      license = licenses.mit;
      sourceProvenance = [sourceTypes.binaryNativeCode];
      mainProgram = "IronyModManager";
    };
  }
