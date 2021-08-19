# based on: https://gist.github.com/buckley310/b4e718e71fb1c7403fb4ceb8fabbc1c4
{ stdenv
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
}:

let
  version = "7.3.1";

  srcName =
    if stdenv.hostPlatform.system == "x86_64-linux" then
      "PacketTracer_${builtins.replaceStrings [ "." ] [ "" ] version}_amd64.deb"
    else throw "Unsupported system: ${stdenv.hostPlatform.system}";

  ptFiles = stdenv.mkDerivation {
    name = "PacketTracer7drv";
    inherit version;

    src = builtins.fetchurl {
      url = "https://github.com/lucasew/nixcfg/releases/download/debureaucracyzzz/PacketTracer_731_amd64.deb";
      sha256 = "c39802d15dd61d00ba27fb8c116da45fd8562ab4b49996555ad66b88deace27f";
    };

    nativeBuildInputs = [ dpkg makeWrapper ];

    dontUnpack = true;
    installPhase = ''
      dpkg-deb -x $src $out
      makeWrapper "$out/opt/pt/bin/PacketTracer7" "$out/bin/packettracer7" \
          --prefix LD_LIBRARY_PATH : "$out/opt/pt/bin"
    '';
  };

  desktopItem = makeDesktopItem {
    name = "cisco-pt7.desktop";
    desktopName = "Packet Tracer 7";
    icon = "${ptFiles}/opt/pt/art/app.png";
    exec = "packettracer %f";
    mimeType = "application/x-pkt;application/x-pka;application/x-pkz;";
  };

in
buildFHSUserEnv {
  name = "packettracer7";
  runScript = "${ptFiles}/bin/packettracer7";

  extraInstallCommands = ''
    mkdir -p "$out/share/applications"
    cp "${desktopItem}"/share/applications/* "$out/share/applications/"
  '';

  targetPkgs = pkgs: [
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
}
