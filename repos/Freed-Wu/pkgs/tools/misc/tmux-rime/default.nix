{ lib
, stdenv
, xmake
, fetchFromGitHub
, unzip
, glib
, librime
, pkg-config
}:
stdenv.mkDerivation rec {
  pname = "tmux-rime";
  version = "0.0.3";
  src = fetchFromGitHub {
    owner = "Freed-Wu";
    repo = pname;
    rev = version;
    fetchSubmodules = false;
    sha256 = "sha256-DCSeENxxXycCqQKv+8mPGy3sxF5CRHUPUaI9wRpEw8Q=";
  };

  nativeBuildInputs = [ stdenv.cc unzip pkg-config xmake ];
  buildInputs = [ glib.dev librime ];

  postPatch = ''
    substituteInPlace xmake.lua --replace-quiet "glib" "glib-2.0"
  '';

  # https://github.com/xmake-io/xmake/discussions/5699
  configurePhase = ''
    export XMAKE_ROOT=y
    HOME=$PWD PATH=$HOME:$PATH
    echo -e "#!$SHELL\necho I am git" > $HOME/git
    chmod +x $HOME/git
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
