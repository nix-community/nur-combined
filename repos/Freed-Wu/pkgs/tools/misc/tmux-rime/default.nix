{ lib
, stdenv
, fetchFromGitHub
, unzip
, glib
, librime
, pkg-config
}:
stdenv.mkDerivation rec {
  pname = "tmux-rime";
  version = "0.0.1";
  src = fetchFromGitHub {
    owner = "Freed-Wu";
    repo = pname;
    rev = version;
    fetchSubmodules = false;
    sha256 = "sha256-zZ6+sZhJW91/TiF6aR0n44jCj2iEkL+RzdEVTw6G9K8=";
  };

  nativeBuildInputs = [ glib.dev stdenv.cc unzip pkg-config ];
  buildInputs = [ glib librime ];

  buildPhase = ''
    cc -otmux-rime *.c ''$(pkg-config --cflags --libs glib-2.0 rime)
  '';

  installPhase = ''
    install -D tmux-rime -t $out/bin
  '';

  meta = with lib; {
    homepage = "https://github.com/Freed-Wu/tmux-rime";
    description = "rime for tmux";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
