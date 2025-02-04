{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
}:

stdenv.mkDerivation rec {
  pname = "3dstools";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "devkitPro";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-2JVtsyFi42sEEZf13Ei+tuLSD4u58IO3xj4bMZtq3zM=";
  };

  nativeBuildInputs = [
    autoconf
    automake
  ];

  preConfigure = ''
    bash ./autogen.sh
  '';

  meta = with lib; {
    description = "Tools for 3DS homebrew";
    homepage = "https://github.com/devkitpro/3dstools";
    platforms = platforms.all;
  };
}
