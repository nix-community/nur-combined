{
  lib,
  fetchurl,
  appimageTools,
  zstd,
  glib,
  icu,
  fontconfig,
  freetype,
  libglvnd,
  libxkbcommon,
  libx11,
  libxext,
  libxrandr,
  libxfixes,
  libxcomposite,
  libxdamage,
  libxtst,
  libxcb,
  libxcb-cursor,
  libxcb-image,
  libxcb-keysyms,
  libxcb-render-util,
  libxcb-wm,
  alsa-lib,
  dbus,
  brotli,
  libkrb5,
  nspr,
  nss,
  systemd,
  wayland,
  mesa,
  libxkbfile,
  libdrm,
  expat,
}:

let
  pname = "rimsort";
  version = "1.17.0";

  src = fetchurl {
    url = "https://github.com/RimSort/RimSort/releases/download/v${version}/RimSort-v${version}-x86_64.AppImage";
    sha256 = "sha256-I4K6G4w3pHywgF73zEOlR8PNNlAbgo1o1BgFrYHoj2s=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = _pkgs: [
    zstd
    glib
    icu
    fontconfig
    freetype
    libglvnd
    libxkbcommon
    libx11
    libxext
    libxrandr
    libxfixes
    libxcomposite
    libxdamage
    libxtst
    libxcb
    libxcb-cursor
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libxcb-wm
    alsa-lib
    dbus
    brotli
    libkrb5
    nspr
    nss
    systemd
    wayland
    mesa
    libxkbfile
    libdrm
    expat
  ];

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/io.github.rimsort.RimSort.desktop \
      -t $out/share/applications
    substituteInPlace $out/share/applications/io.github.rimsort.RimSort.desktop \
      --replace-fail 'Exec=RimSort' 'Exec=rimsort'
    cp -r ${appimageContents}/usr/share/icons $out/share
  '';

  meta = with lib; {
    description = "Open source mod manager for the video game RimWorld";
    homepage = "https://github.com/RimSort/RimSort";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "rimsort";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
