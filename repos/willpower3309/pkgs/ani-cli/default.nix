{ stdenv, lib, fetchgit, makeWrapper, bash, mpv, curl, ffmpeg }:

# https://nixos.wiki/wiki/Shell_Scripts

stdenv.mkDerivation rec {
  name = "ani-cli";
  version ="1.0";

  src = fetchgit {
    url="https://github.com/pystardust/ani-cli";
    rev="34748e71a58feab8b57b2ac3de700c30a55430cc";
    sha256="0i6cba36c64ghs192fg5r7753bb05i8ckqvnrmb858lwqip28sc3";
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
