{ stdenv, lib, fetchFromGitHub, makeWrapper, bash, mpv, curl, ffmpeg }:

stdenv.mkDerivation rec {
  pname = "ani-cli";
  version = "v2.1";

  src = fetchFromGitHub {
    owner="pystardust";
    repo="ani-cli";
    rev=version;
    sha256="A1c7YdBh2VOhw/xTvhNV50j9n+SELyRTHI5w+AeiWDs=";
  };

  buildInputs = [ bash mpv curl ffmpeg ];
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp ani-cli $out/bin/ani-cli
    wrapProgram $out/bin/ani-cli \
      --prefix PATH : ${lib.makeBinPath [ bash mpv curl ffmpeg ]}
  '';
}
