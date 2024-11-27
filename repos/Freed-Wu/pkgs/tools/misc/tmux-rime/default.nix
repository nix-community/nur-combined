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
  version = "0.0.4";
  srcs = [
    (fetchFromGitHub {
      owner = "Freed-Wu";
      repo = pname;
      rev = version;
      name = pname;
      sha256 = "sha256-hFwq1Qna6DKNGk0U9MpUZT6qcTmJR4FdlS7+4+4wTIY=";
    })
    (fetchFromGitHub {
      owner = "xmake-io";
      repo = "xmake-repo";
      rev = "9e39ee6a9c9a4c43192b95b7efcc95ea1c79a28d";
      name = "xmake-repo";
      sha256 = "sha256-LNXxNJalnJ18T/1JY1b3OxWBT1QMEnJkur2WVYa44aM=";
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
