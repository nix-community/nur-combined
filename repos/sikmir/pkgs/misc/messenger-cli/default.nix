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
  version = "0.3.1";

  src = fetchurl {
    url = "mirror://gnu/gnunet/messenger-cli-${finalAttrs.version}.tar.gz";
    hash = "sha256-Tkpvep2ov6boicTY4iGwi/WV5UiVPkIt1mZjXRnuT4s=";
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
