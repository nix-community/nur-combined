{ stdenv, fetchzip }:
stdenv.mkDerivation rec {
  version = "v1.3.7";
  name = "Sia-${version}";
  src = fetchzip {
    url = "https://sia.tech/static/releases/${name}-linux-amd64.zip";
    sha256 = "1ljzwrlkx4hc16r8siiyakn039afipp95dyr83c8yfq3r3bfasqd";
  };
  phases = "installPhase";
  installPhase = ''
    mkdir -p $out/share/doc
    mkdir -p $out/bin
    mkdir -p $out/share/sia
    cp -a $src/doc $out/share/doc/sia
    cp -a $src/LICENSE $src/README.md $out/share/sia
    cp -a $src/{siac,siad} $out/bin
    cp -a $src/{siac,siad}.sig $out/share/sia/
    '';
}
