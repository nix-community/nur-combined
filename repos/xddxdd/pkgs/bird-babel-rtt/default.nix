{ lib
, sources
, stdenv
, autoreconfHook
, bison
, flex
, readline
, libssh
, ...
} @ args:

stdenv.mkDerivation {
  inherit (sources.bird-babel-rtt) pname version src;

  nativeBuildInputs = [ autoreconfHook bison flex ];
  buildInputs = [ readline libssh ];

  patches = [
    ./dont-create-sysconfdir-2.patch
  ];

  CPP = "${stdenv.cc.targetPrefix}cpp -E";

  configureFlags = [
    "--localstatedir=/var"
    "--runstatedir=/run/bird"
  ];

  meta = with lib; {
    description = "BIRD Internet Routing Daemon";
    homepage = "http://bird.network.cz";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
}
