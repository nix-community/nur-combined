{
  fetchFromGitHub,
  stdenv,
  lib,
  autoconf,
  automake,
  pkg-config,
  zlib,
  lz4,
}:

stdenv.mkDerivation rec {
  pname = "switch-tools";
  version = "1.13.1";

  src = fetchFromGitHub {
    owner = "switchbrew";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-WI8sHucTeZOCQWlVdv5fFHK1ENdajUVXlvaW1lJfSMc=";
  };

  preConfigure = ''
    ./autogen.sh
  '';

  buildInputs = [
    lz4
    zlib
  ];
  nativeBuildInputs = [
    autoconf
    automake
    pkg-config
  ];

  meta = with lib; {
    description = "Various Nintendo Switch homebrew tools";
    homepage = "https://github.com/switchbrew/switch-tools";
    platforms = platforms.all;
  };
}
