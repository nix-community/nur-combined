# based on: https://gist.github.com/buckley310/b4e718e71fb1c7403fb4ceb8fabbc1c4
# FIXME: i'm broken
{ 
  pkgs
, stdenv
, requireFile
, dpkg
, makeWrapper
, buildFHSUserEnv
, makeDesktopItem
, alsaLib
, dbus
, expat
, fontconfig
, glib
, libglvnd
, libpulseaudio
, libudev0-shim
, libxkbcommon
, libxml2
, libxslt
, nspr
, nss
, xlibs
, autoPatchelfHook
}:

let
  version = "8";

  ptFiles = stdenv.mkDerivation {
    name = "PacketTracer8drv";
    inherit version;

    src = builtins.fetchurl {
      url = "https://archive.org/download/packet-tracer-800-amd-64-build-212-final/PacketTracer_800_amd64_build212_final.deb";
      sha256 = "1j9mynfybr4lcmh8x36phjx2br09qbhyjcf5schs8gz63sfqz9y9";
    };

    nativeBuildInputs = [ 
      makeWrapper 
      autoPatchelfHook 
    ];
    autoPatchelfIgnoreMissingDeps=true; # testando se ele compilaria
    buildInputs = [
      alsaLib
      dbus
      expat
      fontconfig
      glib
      libglvnd
      libpulseaudio
      libudev0-shim
      libxkbcommon
      libxml2
      libxslt
      nspr
      nss
      xlibs.libICE
      xlibs.libSM
      xlibs.libX11
      xlibs.libXScrnSaver
    ];

    dontUnpack = true;
    unpackPhase = ''
      ${dpkg}/bin/dpkg --fsys-tarfile "$src" | tar --extract
    '';
    installPhase = ''
      cp -R
      chmod 644 "$out" -R
      ls "$out"
      makeWrapper "$out/opt/pt/bin/PacketTracer" "$out/bin/packettracer" \
          --prefix LD_LIBRARY_PATH : "$out/opt/pt/bin" \
          --prefix PTHOME : $out/opt/pt \
          --prefix QT_DEVICE_PIXEL_RATIO : auto
    '';
  };
  # fhs = buildFHSUserEnv {
  #   name = "packettracer";
  #   runScript = "${ptFiles}/bin/packettracer";

  #   targetPkgs = pkgs: with pkgs; [
  #     alsaLib
  #     dbus
  #     expat
  #     fontconfig
  #     glib
  #     libglvnd
  #     libpulseaudio
  #     libudev0-shim
  #     libxkbcommon
  #     libxml2
  #     libxslt
  #     nspr
  #     nss
  #     xlibs.libICE
  #     xlibs.libSM
  #     xlibs.libX11
  #     xlibs.libXScrnSaver
  #   ];
  # };

  desktopItem = makeDesktopItem {
    name = "cisco-pt.desktop";
    desktopName = "Packet Tracer 8";
    icon = "${ptFiles}/opt/pt/art/app.png";
    exec = "${ptFiles}/bin/packettracer %f";
    mimeType = "application/x-pkt;application/x-pka;application/x-pkz;";
  };
  symlink = pkgs.symlinkJoin {
    name = "cisco-packet-tracer8";
    paths = [
      desktopItem
      ptFiles
    ];
  };

in ptFiles
