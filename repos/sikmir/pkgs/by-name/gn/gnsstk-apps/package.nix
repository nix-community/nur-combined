{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gnsstk,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnsstk-apps";
  version = "15.1.1";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "SGL-UT";
    repo = "gnsstk-apps";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iOTSTAt8YKpE6kQvTKlNEE5isOTzbP3+k9ETrWHA+48=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ gnsstk ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_EXT" true)
    (lib.cmakeFeature "CMAKE_CXX_STANDARD" "17")
  ];

  meta = {
    description = "GNSSTk applications suite";
    homepage = "https://github.com/SGL-UT/gnsstk-apps";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isDarwin;
  };
})
