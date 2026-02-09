{
  lib,
  stdenv,
  sources,
  autoPatchelfHook,
  makeBinaryWrapper,
  copyDesktopItems,
  makeDesktopItem,

  dotnetCorePackages,

  brotli,
  bzip2,
  expat,
  fontconfig,
  freetype,
  glib,
  graphite2,
  harfbuzz,
  icu,
  libGL,
  libcap,
  libpng,
  libxkbcommon,
  nss,
  openssl,
  pcre2,
  xorg,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "watt-toolkit";
  inherit (sources."watt-toolkit-x86_64-linux") version;

  sourceRoot = ".";
  src =
    sources."watt-toolkit-${stdenv.hostPlatform.system}".src
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  nativeBuildInputs = [
    autoPatchelfHook
    makeBinaryWrapper
    copyDesktopItems
  ];

  buildInputs = finalAttrs.passthru.runtimeLibs;

  dontBuild = true;

  desktopItems = [
    (makeDesktopItem {
      name = "Watt Toolkit";
      exec = "watt-toolkit";
      icon = "watt-toolkit";
      desktopName = "Watt Toolkit";
      comment = "A cross-platform Steam toolbox.";
      keywords = [
        "Steam"
        "Steam++"
        "WattToolkit"
      ];
      categories = [
        "Utility"
        "Network"
      ];
      extraConfig = {
        "Comment[zh_CN]" = "一个开源跨平台的多功能Steam工具箱。";
        StartupWMClass = "Steam++";
      };
    })
  ];

  installPhase = ''
    runHook preInstall

    install -d $out/lib/watt-toolkit $out/share/icons/hicolor/512x512/apps

    cp -r assemblies native modules $out/lib/watt-toolkit/

    install -Dm755 script/environment_check.sh $out/lib/watt-toolkit/script/environment_check.sh

    install -Dm644 Icons/Watt-Toolkit.png $out/share/icons/hicolor/512x512/apps/watt-toolkit.png

    makeWrapper "${lib.getExe dotnetCorePackages.runtime_9_0}" "$out/bin/watt-toolkit" \
      --add-flags "$out/lib/watt-toolkit/assemblies/Steam++.dll" \
      --set DOTNET_ROOT "${dotnetCorePackages.runtime_9_0}/share/dotnet" \
      --prefix PATH : "${lib.makeBinPath [ nss ]}" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.passthru.runtimeLibs}"

    # SUID hack
    wrapProgram $out/lib/watt-toolkit/modules/Accelerator/Steam++.Accelerator
    rm $out/lib/watt-toolkit/modules/Accelerator/Steam++.Accelerator
    ln -s /run/wrappers/bin/watt-toolkit-accelerator $out/lib/watt-toolkit/modules/Accelerator/Steam++.Accelerator

    runHook postInstall
  '';

  passthru = {
    runtimeLibs = [
      brotli
      bzip2
      expat
      fontconfig
      freetype
      glib
      graphite2
      harfbuzz
      icu
      libGL
      libcap
      libpng
      libxkbcommon
      openssl
      pcre2
      zlib
      # X11 libs
      xorg.libICE
      xorg.libSM
      xorg.libX11
      xorg.libXcursor
      xorg.libXext
      xorg.libXfixes
      xorg.libXi
      xorg.libXrandr
      xorg.libXrender
      xorg.libXtst
    ];
  };

  meta = {
    description = "Steam++ (Watt Toolkit)";
    homepage = "https://steampp.net/";
    license = lib.licenses.gpl3Only;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "watt-toolkit";
  };
})
