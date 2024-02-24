{ lib
, stdenv
, fetchurl
, cmake
, meson
, ninja
, pkg-config
, check
, gnunet
, libextractor
, libgcrypt
, libsodium
}:

stdenv.mkDerivation rec {
  pname = "libgnunetchat";
  version = "0.1.3";

  src = fetchurl {
    url = "mirror://gnu/gnunet/libgnunetchat-${version}.tar.xz";
    hash = "sha256-+lRjKQsYyyYVxhhgwLE9RNVe0LsT4rTNOqKiJVkAXpI=";
  };

  postPatch = ''
    # The major and minor version should be identical, but currently they don't:
    # GNUNET_MESSENGER_VERSION 0x00000002
    # GNUNET_CHAT_VERSION      0x000000010000L
    substituteInPlace src/gnunet_chat_lib.c \
      --replace-fail "GNUNET_CHAT_VERSION_ASSERT();" ""
  '';

  nativeBuildInputs = [ meson cmake ninja pkg-config ];

  buildInputs = [ check gnunet libextractor libgcrypt libsodium ];

  doCheck = false;

  meta = with lib; {
    description = "A client-side library for applications to utilize the Messenger service of GNUnet";
    homepage = "https://www.gnunet.org/";
    changelog = "https://git.gnunet.org/libgnunetchat.git/tree/ChangeLog?h=v${version}";
    license = licenses.agpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
