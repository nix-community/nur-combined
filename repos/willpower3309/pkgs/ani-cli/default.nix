{ stdenv, lib, fetchFromGitHub, makeWrapper, bash, mpv, curl, ffmpeg }:

# https://nixos.wiki/wiki/Shell_Scripts

stdenv.mkDerivation rec {
  name = "ani-cli";
  version ="1.0";

  src = fetchFromGitHub {
    owner="pystardust";
    repo="ani-cli";
    rev="c76860dff22834b9d123cbe11804896de040e547";
    sha256="CP5ahipruXJNa4JQLXCqciEKwxqKbguT+V8mRi0NGxg=";
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
