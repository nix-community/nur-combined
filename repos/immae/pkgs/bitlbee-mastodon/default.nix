{ stdenv, fetchFromGitHub, autoreconfHook, pkgconfig, bitlbee, glib, lib }:
stdenv.mkDerivation rec {
  name = "bitlbee-mastodon-${version}";
  version = "v1.4.4";

  src = fetchFromGitHub {
    rev = version;
    owner = "kensanata";
    repo = "bitlbee-mastodon";
    sha256 = "0a8196pyr6bjnqg82zn7jdhiv7xsg4npbpzalla1i2h99j30q8pk";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig ];
  buildInputs = [ bitlbee glib ];

  preConfigure = ''
    export BITLBEE_PLUGINDIR=$out/lib/bitlbee
    export BITLBEE_DATADIR=$out/share/bitlbee
    chmod +x autogen.sh
    ./autogen.sh
  '';

  meta = {
    description = "Bitlbee plugin for Mastodon";

    homepage = https://github.com/kensanata/bitlbee-mastodon;
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
  };
}
