{ lib
, stdenvNoCC
, fetchFromGitHub
, makeWrapper
, bash
, curl
, jp2a
, neofetch
, imagemagick
}:

let
  name = "hentaifetch";
  version = "2021-04-28";
in
stdenvNoCC.mkDerivation {
  inherit name version;
  src = fetchFromGitHub {
    owner = "helpmeplsfortheloveofgod";
    repo = name;
    rev = "ff065dc2f151663f14d972157e4da28fb78c6aaa";
    sha256 = "00j8y9krgc9g395fznxrr1lpkvp1ziggcrgpfp939x64ajw0bl4a";
  };

  buildInputs = [ bash ];
  nativeBuildInputs = [ makeWrapper ];

  buildPhase = "";

  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 hentaifetch $out/bin/
    wrapProgram $out/bin/hentaifetch \
      --prefix PATH : ${lib.makeBinPath [ curl jp2a neofetch imagemagick ]}
  '';

  meta = with lib; {
    description = "Neofetch but with hentai";
    homepage = "https://github.com/helpmeplsfortheloveofgod/hentaifetch";
    license = licenses.gpl3;
    maintainers = "VojtechStep";
    platforms = platforms.unix;
  };
}
