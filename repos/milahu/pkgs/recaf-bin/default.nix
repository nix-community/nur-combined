/*
nix-build -E 'with import <nixpkgs> { }; callPackage ./default.nix { }'
*/
/* TODO dependencies
javafx-media-16-linux.jar
javafx-graphics-16-linux.jar
javafx-controls-16-linux.jar
javafx-base-16-linux.jar
*/
{ stdenv
, lib
, fetchurl
, writeShellScript
, jre
, steam-run # fix: libX11.so.6: No such file
}:
stdenv.mkDerivation rec {
  pname = "recaf-bin";
  version = "2.21.0";
  src = fetchurl {
    url = "https://github.com/Col-E/Recaf/releases/download/2.21.0/recaf-2.21.0-J8-jar-with-dependencies.jar";
    sha256 = "1cr5akf8j9zyqlv66s5kxqiax0n6sdbp03ab1hc2pq0g8xcz13sr";
  };
  dontUnpack = true;
  buildInputs = [
    jre
  ];
  wrapper = writeShellScript "recaf-wrapper" ''
    PATH=$PATH:${lib.makeBinPath [ steam-run jre ]}
    steam-run java -jar $(dirname $0)/../lib/recaf.jar "$@"
  '';
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib
    cp ${src} $out/lib/recaf.jar
    cp ${wrapper} $out/bin/recaf
  '';
  meta = with lib; {
    homepage = "https://github.com/Col-E/Recaf";
    description = "Java bytecode editor (binary release)";
    license = licenses.mit;
    #platforms = platforms.unix; actually all platforms ...
    #maintainers = with maintainers; [  ];
  };
}
