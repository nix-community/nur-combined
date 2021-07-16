{ stdenv
, lib
, makeWrapper
, fetchurl
, makeDesktopItem
, copyDesktopItems
, imagemagick
, openjdk11
, dpkg
, writeScript
, coreutils
, bash
, tor
, psmisc
, gnutar
, zip
, xz
}:
let
  bisq-launcher = writeScript "bisq-launcher" ''
    #! ${bash}/bin/bash

    # This is just a comment to convince Nix that Tor is a
    # runtime dependency; The Tor binary is in a *.jar file.
    # ${tor}/bin/tor

    JAVA_TOOL_OPTIONS="-XX:MaxRAM=4g" bisq-desktop-wrapped "$@"
  '';
in
stdenv.mkDerivation rec {
  version = "1.7.1";
  pname = "bisq-desktop";
  nativeBuildInputs = [ makeWrapper copyDesktopItems dpkg gnutar zip xz ];

  src = fetchurl {
    url = "https://github.com/bisq-network/bisq/releases/download/v${version}/Bisq-64bit-${version}.deb";
    sha256 = "1r7nl6ny6gq6jmvpz0cdrawzfdn2lf8i58xldwln146ccf0ncdxn";
  };

  desktopItems = [
    (makeDesktopItem {
      name = "Bisq";
      exec = "bisq-desktop";
      icon = "bisq";
      desktopName = "Bisq ${version}";
      genericName = "Decentralized bitcoin exchange";
      categories = "Network;P2P;";
    })
  ];

  unpackPhase = ''
    dpkg -x $src .
  '';

  buildPhase = ''
    # Replace the embedded Tor binary (which is in a Tar achive)
    # with one from Nixpkgs.

    mkdir -p native/linux/x64/
    cp ${tor}/bin/tor ./
    ${gnutar}/bin/tar -cJf native/linux/x64/tor.tar.xz tor
    ${zip}/bin/zip -r opt/bisq/lib/app/desktop-${version}-all.jar native
  '';

  installPhase = ''
    mkdir -p $out/lib $out/bin
    cp opt/bisq/lib/app/desktop-${version}-all.jar $out/lib

    makeWrapper ${openjdk11}/bin/java $out/bin/bisq-desktop-wrapped \
      --add-flags "-jar $out/lib/desktop-${version}-all.jar bisq.desktop.app.BisqAppMain"

    makeWrapper ${bisq-launcher} $out/bin/bisq-desktop \
      --prefix PATH : $out/bin

    copyDesktopItems

    for n in 16 24 32 48 64 96 128 256; do
      size=$n"x"$n
      ${imagemagick}/bin/convert opt/bisq/lib/Bisq.png -resize $size bisq.png
      install -Dm644 -t $out/share/icons/hicolor/$size/apps bisq.png
    done;
  '';

  meta = with lib; {
    description = "A decentralized bitcoin exchange network";
    homepage = "https://bisq.network";
    license = licenses.mit;
    maintainers = with maintainers; [ juaningan emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
