{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnsstk";
  version = "15.3.1";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "SGL-UT";
    repo = "gnsstk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-o2iL7Wh3dioxyIzDcVlsN20c40BSrc5+mFYISJ9YlpY=";
  };

  postPatch = ''
    sed -i '43i #include <cstdint>' core/lib/NewNav/GLOCNavHeader.hpp
  '';

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_EXT" true)
  ];

  meta = {
    description = "GNSSTk libraries";
    homepage = "https://github.com/SGL-UT/gnsstk";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
