{ stdenv, fetchFromGitHub, autoreconfHook, pkgconfig, bitlbee, glib, lib }:
stdenv.mkDerivation rec {
  name = "bitlbee-mastodon-${version}";
  version = "v1.4.2";

  src = fetchFromGitHub {
    rev = version;
    owner = "kensanata";
    repo = "bitlbee-mastodon";
    sha256 = "04rakgr1pfsg1vhfwlfbggbzw249j7dmk88xrsnf3n84c5ccdyas";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig ];
  buildInputs = [ bitlbee glib ];

  preConfigure = ''
    export BITLBEE_PLUGINDIR=$out/lib/bitlbee
    ./autogen.sh
  '';

  meta = {
    description = "Bitlbee plugin for Mastodon";

    homepage = https://github.com/kensanata/bitlbee-mastodon;
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
  };
}
