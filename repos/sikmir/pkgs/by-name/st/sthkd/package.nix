{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sthkd";
  version = "0-unstable-2020-11-15";

  src = fetchFromGitHub {
    owner = "jeremybobbin";
    repo = "sthkd";
    rev = "2cb198a8e0bc46b9e88c4a7b0f533b35d197a8f0";
    hash = "sha256-P7RWdsxYv/P7K+BfvzkOzCCSMppSxacKVj19MPgeV7I=";
  };

  makeFlags = [ "CC:=$(CC)" ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Simple Terminal Hotkey Daemon";
    homepage = "https://github.com/jeremybobbin/sthkd";
    license = lib.licenses.isc;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.sikmir ];
    skip.ci = stdenv.isDarwin;
  };
})
