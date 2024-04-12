{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jrl-cmakemodules";
  version = "unstable-2024-04-11";


  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = finalAttrs.pname;
    rev = "da417084419e911f8b5cb0bf376f24d2345555af";
    hash = "sha256-U0EmKy2to8zKfGR8NA+pWHSXb7yFture8I6fsJONbPw=";
  };

  nativeBuildInputs = [ cmake ];

  meta = {
    description = "CMake utility toolbox";
    homepage = "https://github.com/jrl-umi3218/jrl-cmakemodules";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ lib.maintainers.nim65s ];
  };
})
