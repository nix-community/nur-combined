{
  lib,
  stdenv,
  fetchurl,
  cmake,
  meson,
  ninja,
  pkg-config,
  gnunet,
  libgcrypt,
  libgnunetchat,
  libsodium,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "messenger-cli";
  version = "0.2.0";

  src = fetchurl {
    url = "mirror://gnu/gnunet/messenger-cli-${finalAttrs.version}.tar.gz";
    hash = "sha256-ZuGflZsMzPZ430boN/LKtEthayyyrxY0uIIWQasU7vY=";
  };

  nativeBuildInputs = [
    meson
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    gnunet
    libgcrypt
    libgnunetchat
    libsodium
    ncurses
  ];

  meta = {
    description = "A CLI for the Messenger service of GNUnet";
    homepage = "https://www.gnunet.org/";
    changelog = "https://git.gnunet.org/messenger-cli.git/tree/ChangeLog?h=v${finalAttrs.version}";
    license = lib.licenses.agpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
