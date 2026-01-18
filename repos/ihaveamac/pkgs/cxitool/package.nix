{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
}:

stdenv.mkDerivation rec {
  pname = "cxitool";
  version = "unstable-2019-04-10";

  src = fetchFromGitHub {
    owner = "devkitPro";
    repo = "3dstools";
    rev = "26a73b75d37db9c5be2e6ea172ddfc0c6f278bea";
    hash = "sha256-isDEatlXm/B3opafjz3uT2nXtvBXTCzvEEh0GSGPruI=";
  };

  nativeBuildInputs = [
    autoconf
    automake
  ];

  preConfigure = ''
    substituteInPlace Makefile.am \
      --replace-fail "bin_PROGRAMS = 3dsxtool 3dsxdump smdhtool cxitool" "bin_PROGRAMS = cxitool"
    bash autogen.sh
  '';

  meta = with lib; {
    description = "Convert 3dsx to CXI";
    homepage = "https://github.com/devkitpro/3dstools";
    platforms = platforms.all;
    mainProgram = "cxitool";
  };
}
