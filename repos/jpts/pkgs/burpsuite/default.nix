{ lib
, fetchurl
, jre
, unzip
, makeDesktopItem
, stdenv
, pkgs
, makeWrapper
}:
let
  version = "2023.10.2.2";
in
stdenv.mkDerivation {
  name = "burpsuite";
  description = "An integrated platform for performing security testing of web applications";
  inherit version;

  src = fetchurl {
    name = "burpsuite.jar";
    urls = [
      "https://portswigger.net/burp/releases/download?productId=100&version=${version}&type=Jar"
      "https://web.archive.org/web/https://portswigger.net/burp/releases/download?productId=100&version=${version}&type=Jar"
    ];
    hash = "sha256-I07XWAtSuV5/nFxessUxtdaHQgPCs2T4vdztWQAC2bQ=";
  };

  sourceRoot = ".";

  buildInputs = with pkgs; [
    cairo
    expat
    glib
    gtk3
    nspr
    nss
    pango
  ] ++ lib.optionals stdenv.isLinux [
    alsa-lib
    at-spi2-core
    cups
    dbus
    libdrm
    libudev0-shim
    libxkbcommon
    mesa.drivers
    xorg.libX11
    xorg.libxcb
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
  ];

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];
  #buildPhase = ''
  #'';

  installPhase = ''
    install -Dm755 $src $out/share/burpsuite/burpsuite.jar
    mkdir -p "$out/share/pixmaps"
    ${lib.getBin unzip}/bin/unzip -p $src resources/Media/icon64community.png > "$out/share/pixmaps/burpsuite.png"

    mkdir -p $out/bin
    makeWrapper ${jre}/bin/java $out/bin/burpsuite \
      --add-flags "-jar $out/share/burpsuite/burpsuite.jar --disable-auto-update"
  '';


  meta = with lib; {
    description = "";
    longDescription = ''
      Burp Suite is an integrated platform for performing security testing of web applications.
      Its various tools work seamlessly together to support the entire testing process, from
      initial mapping and analysis of an application's attack surface, through to finding and
      exploiting security vulnerabilities.
    '';
    homepage = "https://portswigger.net/burp/";
    downloadPage = "https://portswigger.net/burp/freedownload";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    license = licenses.unfree;
    platforms = jre.meta.platforms;
    hydraPlatforms = [ ];
    maintainers = with maintainers; [ bennofs ];
  };
}
