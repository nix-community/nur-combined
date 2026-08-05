{
  lib,
  appimageTools,
  autoPatchelfHook,
  fetchurl,
  fontconfig,
  freetype,
  gtk3,
  libGL,
  libx11,
  libxcb,
  libxcursor,
  libxfixes,
  libxi,
  libxkbcommon,
  libxrandr,
  libxrender,
  makeWrapper,
  stdenv,
  udev,
  wayland,
}:

let
  pname = "meatshell";
  sources = {
    x86_64-linux = import ./sources/x86_64-linux.nix;
    aarch64-linux = import ./sources/aarch64-linux.nix;
  };
  source =
    sources.${stdenv.hostPlatform.system}
      or (throw "meatshell-bin is unsupported on ${stdenv.hostPlatform.system}");
  inherit (source) version;
  src = fetchurl {
    inherit (source) url hash;
  };
  appimageRuntimeLibraries = [
    fontconfig
    freetype
    gtk3
    libGL
    libx11
    libxcb
    libxcursor
    libxfixes
    libxi
    libxkbcommon
    libxrandr
    libxrender
    udev
    wayland
  ];
  tarballRuntimeLibraries = [
    fontconfig
    freetype
    libGL
    libx11
    libxcb
    libxcursor
    libxi
    libxkbcommon
    libxrender
    stdenv.cc.cc.lib
    wayland
  ];
  commonMeta = {
    description = "Lightweight FinalShell-style SSH and terminal client";
    homepage = "https://github.com/yituorou/meatshell";
    changelog = "https://github.com/yituorou/meatshell/releases/tag/v${version}";
    license = with lib.licenses; [
      mit
      asl20
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "meatshell";
    platforms = builtins.attrNames sources;
  };
  appimagePackage = appimageTools.wrapType2 {
    inherit pname version src;

    extraPkgs = _: appimageRuntimeLibraries;

    extraInstallCommands =
      let
        contents = appimageTools.extractType2 {
          inherit pname version src;
        };
      in
      ''
        desktopFile="$(find ${contents} -path '*/share/applications/*.desktop' -print -quit)"
        if [ -n "$desktopFile" ]; then
          install -Dm444 "$desktopFile" "$out/share/applications/meatshell.desktop"
          sed -i \
            -e 's|^Exec=.*|Exec=meatshell|' \
            "$out/share/applications/meatshell.desktop"
        fi

        if [ -d ${contents}/usr/share/icons ]; then
          cp -r ${contents}/usr/share/icons "$out/share/"
        fi
      '';

    meta = commonMeta;
  };
  tarballPackage = stdenv.mkDerivation {
    inherit pname version src;
    inherit (source) sourceRoot;

    nativeBuildInputs = [
      autoPatchelfHook
      makeWrapper
    ];

    buildInputs = tarballRuntimeLibraries;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      install -Dm755 meatshell "$out/bin/meatshell"
      install -Dm644 meatshell.desktop "$out/share/applications/meatshell.desktop"
      install -Dm644 icon@512.png \
        "$out/share/icons/hicolor/512x512/apps/meatshell.png"

      runHook postInstall
    '';

    postFixup = ''
      wrapProgram "$out/bin/meatshell" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath tarballRuntimeLibraries}"
    '';

    meta = commonMeta;
  };
in
if source.format == "appimage" then appimagePackage else tarballPackage
