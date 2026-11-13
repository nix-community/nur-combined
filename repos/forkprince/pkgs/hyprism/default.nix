{
  vulkan-loader,
  appimageTools,
  stdenvNoCC,
  fontconfig,
  libXcursor,
  libXrender,
  libXfixes,
  libXrandr,
  fetchurl,
  freetype,
  libXext,
  openssl,
  libICE,
  libX11,
  libGL,
  libSM,
  libXi,
  dbus,
  gtk3,
  zlib,
  _7zz,
  icu,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "hyprism";
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);
  inherit (ver) version;

  meta = {
    description = "Unofficial, cross-platform Hytale launcher with isolated instances, mod discovery, and profile management";
    homepage = "https://github.com/hyprismteam/Hyprism";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [Prinky];
    platforms = lib.platforms.darwin ++ ["x86_64-linux"];
    mainProgram = "hyprism";
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
in
  if stdenvNoCC.hostPlatform.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;

      nativeBuildInputs = [_7zz];
    })
  else let
    contents = appimageTools.extract {inherit pname version src;};
  in
    lib.helper.mkAppImage {
      inherit pname version src meta;

      desktopName = "Hyprism";
      categories = ["Game"];
      icon = "io.github.hyprismteam.Hyprism";

      extraPkgs = [
        vulkan-loader
        fontconfig
        libXcursor
        libXrender
        libXfixes
        libXrandr
        freetype
        libXext
        openssl
        libICE
        libX11
        libSM
        libGL
        libXi
        dbus
        gtk3
        zlib
        icu
      ];

      extraInstallCommands = ''
        install -Dm444 ${contents}/io.github.hyprismteam.Hyprism.svg $out/share/icons/hicolor/scalable/apps/io.github.hyprismteam.Hyprism.svg
      '';
    }
