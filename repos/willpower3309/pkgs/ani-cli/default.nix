{ stdenv, lib, fetchFromGitHub, makeWrapper, bash, mpv, curl, ffmpeg }:

# https://nixos.wiki/wiki/Shell_Scripts

stdenv.mkDerivation rec {
  name = "ani-cli";
  version ="1.0";

  src = fetchFromGitHub {
    owner="pystardust";
    repo="ani-cli";
    rev="865fec2c72449169bd8b101665c70de77859f83c";
    sha256="u3DosXWpq/uIiQjmugWLir701TDqfDnK7CrtfbT+jEM=";
  };

  buildInputs = [ bash mpv curl ffmpeg ];
  nativeBuildInputs = [ makeWrapper ];

  configurePhase = ''
    rm Makefile
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ani-cli $out/bin/ani-cli
    wrapProgram $out/bin/ani-cli \
      --prefix PATH : ${lib.makeBinPath [ bash mpv curl ffmpeg ]}
  '';
}
