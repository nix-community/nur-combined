{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  raylib,
  sfml,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tgui";
  version = "1.13.0";

  src = fetchFromGitHub {
    owner = "texus";
    repo = "TGUI";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6Udt33WSAUYWiQyoCsvMckpGH9Oj5NEtjAGNLuLRvvw=";
  };

  postPatch = ''
    substituteInPlace cmake/pkgconfig/tgui.pc.in \
      --replace '$'{exec_prefix}/@CMAKE_INSTALL_LIBDIR@ @CMAKE_INSTALL_FULL_LIBDIR@
  '';

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    (lib.cmakeBool "TGUI_HAS_BACKEND_RAYLIB" true)
    (lib.cmakeFeature "TGUI_BACKEND" "Custom")
  ];

  buildInputs = [
    raylib
  ];

  meta = {
    description = "Cross-platform modern c++ GUI";
    homepage = "https://github.com/texus/TGUI";
    license = lib.licenses.zlib;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
