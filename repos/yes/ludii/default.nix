{ lib
, stdenv
, fetchurl
, jre
, makeDesktopItem
, rp ? ""
}:

stdenv.mkDerivation rec {
  pname = "ludii";
  version = "1.3.12";

  src = fetchurl {
    url = "${rp}https://ludii.games/downloads/Ludii-${version}.jar";
    hash = "sha256:c26a595220fa136ec7a528ae41d46f5a7944f0353062ae0dc765a2c3aa0bd426";
  };

  icon = fetchurl {
    url = "https://cdn.jsdelivr.net/gh/Ludeme/Ludii@f6b276c47605348da521ed1bb19581d697df5915/resources/ludii-logo-64x64.png";
    hash = "sha256:42b13a0a6b28d66da51d56de4f683c7b6d088bad5df598fa3358b03f7b255ad1";
  };

  desktopItem = makeDesktopItem {
    desktopName = "Ludii";
    name = pname;
    exec = pname;
    icon = pname;
    categories = [ "Game" ];
    comment = meta.description;
  };

  dontUnpack = true;

  installPhase = ''
    export dest=$out/share/$pname/$pname.jar
    export java=${jre}/bin/java

    install -D $src $dest
    install -D $icon $out/share/icons/hicolor/64x64/apps/$pname.png
    ln -s $desktopItem/share/applications $out/share/

    mkdir -p $out/bin
    substituteAll ${./ludii.sh} $out/bin/ludii
    chmod +x $out/bin/ludii
  '';

  meta = {
    description = "A general game system being developed as part of the ERC-funded Digital Ludeme Project (DLP)";
    homepage = "https://ludii.games/";
    license = lib.licenses.cc-by-nc-nd-40;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
  };
}