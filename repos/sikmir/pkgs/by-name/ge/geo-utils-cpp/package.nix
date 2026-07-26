{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gtest,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "geo-utils-cpp";
  version = "1.2.2";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "gistrec";
    repo = "geo-utils-cpp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rB/VYcPNlthClue2W/L8FdV8QN6MM/260XLRILLzrhs=";
  };

  postPatch = ''
    substituteInPlace cmake/geo-utils-cpp.pc.in \
      --replace-fail 'includedir=''${prefix}/@CMAKE_INSTALL_INCLUDEDIR@' "includedir=@CMAKE_INSTALL_FULL_INCLUDEDIR@" \
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [ gtest ];

  meta = {
    description = "Tiny header-only C++17 library for lat/lng geometry";
    homepage = "https://github.com/gistrec/geo-utils-cpp";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
