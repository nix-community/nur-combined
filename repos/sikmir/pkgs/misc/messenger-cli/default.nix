{ lib, stdenv, fetchurl, cmake, meson, ninja, pkg-config
, gnunet, libgcrypt, libgnunetchat, libsodium, ncurses
}:

stdenv.mkDerivation rec {
  pname = "messenger-cli";
  version = "0.1.1";

  src = fetchurl {
    url = "mirror://gnu/gnunet/messenger-cli-${version}.tar.xz";
    hash = "sha256-j2Z8AFeQJjsnkWpY9q6x6TJ5oVldhucx4iKfpBAT1os=";
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

  meta = with lib; {
    description = "A CLI for the Messenger service of GNUnet";
    homepage = "https://www.gnunet.org/";
    changelog = "https://git.gnunet.org/messenger-cli.git/tree/ChangeLog?h=v${version}";
    license = licenses.agpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
