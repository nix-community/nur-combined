{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lunasvg";
  version = "3.2.1";

  src = fetchFromGitHub {
    owner = "sammycage";
    repo = "lunasvg";
    rev = "v${finalAttrs.version}";
    hash = "sha256-358zyWbrbrc7riJvNf6/XYb93FTDDX/73DVxjN23Gmo=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = lib.optionals (!stdenv.hostPlatform.isStatic) [ "-DBUILD_SHARED_LIBS:BOOL=ON" ];

  meta = {
    description = "Standalone C++ library to create, animate, manipulate and render SVG files";
    homepage = "https://github.com/sammycage/lunasvg";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
})
