{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jrl-cmakemodules";
  version = "unstable-2024-04-10";

  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = finalAttrs.pname;
    rev = "702182ea008cb6805c9e11abbe85801b07cade3f";
    hash = "sha256-20129fOqGonCa4z+kwK5LCKoHmLO1ddjoUFvmTGaURY=";
  };

  nativeBuildInputs = [ cmake ];

  meta = {
    description = "CMake utility toolbox";
    homepage = "https://github.com/jrl-umi3218/jrl-cmakemodules";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ lib.maintainers.nim65s ];
  };
})
