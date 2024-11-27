{
  lib,
  stdenv,
  fetchFromGitHub,
  byacc,
  cmake,
  flex,
  meson,
  ninja,
  pkg-config,
  libedit,
  libxo,
  ncurses6,
  openssl,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bsdutils";
  version = "13.2";

  src = fetchFromGitHub {
    owner = "dcantrell";
    repo = "bsdutils";
    rev = "refs/tags/${finalAttrs.version}";
    hash = "sha256-sYxx79wQu1HFYKHYgRHqAA2sATXZ7WTxIZB6KBVnatU=";
  };

  nativeBuildInputs = [
    byacc
    cmake # Meson crashes without this.
    flex
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    libedit
    libxo
    ncurses6
    openssl
  ];

  dontUseCmakeConfigure = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Alternative to GNU coreutils using software from FreeBSD";
    homepage = "https://github.com/dcantrell/bsdutils";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
