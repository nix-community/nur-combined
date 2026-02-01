{
  lib,
  stdenv,
  pkgs,
  fetchzip,
  writeShellScriptBin,
  glib,
  gtk3,
  xorg,
  cairo,
  pango,
  gdk-pixbuf,
  alsa-lib,
  fontconfig,
  freetype,
  libpng,
  zlib,
  dbus,
  jdk21_headless,
}:

let
  pname = "eezupnp";
  version = "4.0.0";

  # Pick an FHS env builder that exists in this nixpkgs
  buildFHS =
    if pkgs ? buildFHSUserEnv then
      pkgs.buildFHSUserEnv
    else if pkgs ? buildFHSEnv then
      pkgs.buildFHSEnv
    else if pkgs ? buildFHSUserEnvBubblewrap then
      pkgs.buildFHSUserEnvBubblewrap
    else
      throw "eezupnp: No FHS env builder found in pkgs (expected one of buildFHSUserEnv, buildFHSEnv, buildFHSUserEnvBubblewrap).";

  eezupnp-unpacked = stdenv.mkDerivation {
    inherit pname version;
    src = fetchzip {
      url = "https://www.eezupnp.de/archives/${pname}-${version}.linux.gtk.x86_64.zip";
      sha256 = "aUno5CIDDWLa8jzdBIGFuUUXkAjBGXBthkWt1WkxTZs=";
    };
    dontBuild = true;
    installPhase = ''
      mkdir -p $out
      cp -R ./* $out/
    '';
  };
in
buildFHS {
  name = pname;

  targetPkgs =
    pkgs: with pkgs; [
      glib
      gtk3

      xorg.libX11
      xorg.libXrender
      xorg.libXext
      xorg.libXrandr
      xorg.libXi
      xorg.libXfixes
      xorg.libXinerama

      cairo
      pango
      gdk-pixbuf

      alsa-lib
      fontconfig
      freetype
      libpng
      zlib
      dbus

      jdk21_headless
    ];

  runScript = "${writeShellScriptBin "eezupnp-launch" ''
    cd ${eezupnp-unpacked}
    exec ./CP "$@"
  ''}/bin/eezupnp-launch";

  meta = with lib; {
    description = "EEZUPnP UPnP AV MediaServer for Linux";
    homepage = "https://www.eezupnp.de/";
    # proprietary, binary-only:
    license = licenses.unfree;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = platforms.linux;
    mainProgram = "eezupnp";
  };
}
