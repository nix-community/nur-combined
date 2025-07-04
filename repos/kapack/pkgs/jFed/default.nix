{ lib, stdenv, fetchurl, makeWrapper, jre }:

stdenv.mkDerivation rec {
  pname = "jfed_cli";
  version = "250213-166447";
  src = fetchurl {
    url =
      "https://jfed.ilabt.imec.be/releases/develop/${version}/jar/jfed_cli.tar.gz";
    hash = "sha256-W1b3HFd9q2z84zYoEdOdXPZ6KWO/JJcYuL/xLsgblPw=";
  };
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -pv $out/share/java $out/bin
    cp *.jar $out/share/java
    cp -r lib/ $out/share/java/lib

    makeWrapper ${jre}/bin/java $out/bin/jfed-experimenter-cli \
      --add-flags "--add-opens java.base/java.net=ALL-UNNAMED -jar $out/share/java/experimenter-cli.jar"
  '';
}
