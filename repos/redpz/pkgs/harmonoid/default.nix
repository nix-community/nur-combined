{
  fetchurl,
  stdenvNoCC,
  makeWrapper,
  mpv,
  libepoxy,
  harfbuzz,
  lib,
}:
stdenvNoCC.mkDerivation rec {
  name = "harmonoid";
  version = "0.3.10";

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    mpv
    libepoxy
    harfbuzz
  ];

  src = fetchurl {
    url = "https://github.com/alexmercerind2/harmonoid-releases/releases/download/v${version}/harmonoid-linux-x86_64.tar.gz";
    hash = "sha256-GTF9KrcTolCc1w/WT0flwlBCBitskFPaJuNUdxCW9gs=";
  };

  installPhase = ''
    tar -xf $src
    mkdir -p $out
    cp -r usr/bin usr/share $out/
    wrapProgram $out/bin/harmonoid \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          harfbuzz
          mpv
          libepoxy
        ]
      }
  '';

}
