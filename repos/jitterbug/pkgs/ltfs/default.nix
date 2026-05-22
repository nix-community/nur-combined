{
  lib,
  stdenv,
  fetchFromGitHub,
  fuse,
  icu66,
  autoreconfHook,
  autoconf,
  automake,
  libtool,
  pkg-config,
  libxml2,
  libuuid,
  net-snmp,
  maintainers,
  ...

}:
let
  pname = "ltfs";
  version = "2.4.8.2-10520";

  rev = "v${version}";
  hash = "sha256-1+oJyv5FrKc1GkPhARkv+w7CDrW1M8LKRK5Rb6pej5I=";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    inherit hash rev;
    owner = "LinearTapeFileSystem";
    repo = "ltfs";
  };

  env.NIX_CFLAGS_COMPILE = toString [
    "-Wno-error=declaration-after-statement"
  ];

  nativeBuildInputs = [
    autoreconfHook
    autoconf
    automake
    libtool
    pkg-config
    net-snmp
  ];

  buildInputs = [
    fuse
    icu66
    libxml2
    libuuid
  ];

  meta = {
    inherit maintainers;
    description = "Reference LTFS implementation.";
    homepage = "https://github.com/LinearTapeFileSystem/ltfs";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
  };
}
