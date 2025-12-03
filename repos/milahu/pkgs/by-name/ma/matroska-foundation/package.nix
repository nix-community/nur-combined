{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "matroska-foundation";
  version = "unstable-2025-01-19";

  src = fetchFromGitHub {
    owner = "Matroska-Org";
    repo = "foundation-source";
    rev = "abcfeae5e2545c5439c869ade71be627df918709";
    hash = "sha256-hjBHhSmpAHyvlQjB9S30m25V9NSyPzme3KBlWBLg23w=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    zlib
  ];

  meta = {
    description = "LibEBML2, libMatroska2, mkvalidator, mkclean and the specifications";
    homepage = "https://github.com/Matroska-Org/foundation-source";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ];
    # mainProgram = [ "mkvalidator" "mkclean" ];
    mainProgram = "mkvalidator";
    platforms = lib.platforms.all;
  };
}
