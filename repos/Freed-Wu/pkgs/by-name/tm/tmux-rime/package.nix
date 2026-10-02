{
  lib,
  stdenv,
  xmake,
  fetchFromGitHub,
  unzip,
  glib,
  librime,
  pkg-config,
}:
stdenv.mkDerivation rec {
  pname = "tmux-rime";
  version = "0.0.5";
  srcs = [
    (fetchFromGitHub {
      owner = "Freed-Wu";
      repo = pname;
      rev = version;
      name = pname;
      sha256 = "sha256-t+l/37WJ0yVhhPiPuJn/EXBil0r/EPEhoopmVq/Kq9k=";
    })
    (fetchFromGitHub {
      owner = "xmake-io";
      repo = "xmake-repo";
      rev = "5b066a0dcf5ab8b8f7daaa0119defbf2643bc663";
      name = "xmake-repo";
      sha256 = "sha256-PlKAmsY9wuyYxEr0RJABQFzQ6K4c04fYzWC6KfeveO4=";
    })
  ];
  sourceRoot = ".";

  nativeBuildInputs = [
    stdenv.cc
    unzip
    pkg-config
    xmake
  ];
  buildInputs = [
    glib.dev
    librime
  ];

  # https://github.com/xmake-io/xmake/discussions/5699
  configurePhase = ''
    export XMAKE_ROOT=y
    HOME=$PWD PATH=$HOME:$PATH
    echo -e "#!$SHELL\necho I am git" > $HOME/git
    chmod +x $HOME/git
    install -d .xmake/repositories
    ln -sf ../../xmake-repo .xmake/repositories
    cd ${pname}
    xmake g --network=private
    xmake f --verbose
  '';

  buildPhase = ''
    xmake
  '';

  installPhase = ''
    xmake install -o$out
  '';

  meta = with lib; {
    homepage = "https://github.com/Freed-Wu/tmux-rime";
    description = "rime for tmux";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
