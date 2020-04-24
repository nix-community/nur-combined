{ stdenv, fetchzip, autoPatchelfHook }:
stdenv.mkDerivation rec {
  version = "v1.4.3";
  name = "Sia-${version}";
  src = fetchzip {
    url = "https://sia.tech/static/releases/${name}-linux-amd64.zip";
    sha256 = "1i67zjzk4cwfzb1dxaxc1m41fa44sz1d0mf6dmlyg6pm4cyqizki";
  };
  phases = "installPhase fixupPhase";
  nativeBuildInputs = [
    autoPatchelfHook
    ];
  installPhase = ''
    mkdir -p $out/share/doc
    mkdir -p $out/bin
    mkdir -p $out/share/sia
    cp -a $src/doc $out/share/doc/sia
    cp -a $src/LICENSE $src/README.md $out/share/sia
    cp -a $src/{siac,siad} $out/bin
    '';
}
