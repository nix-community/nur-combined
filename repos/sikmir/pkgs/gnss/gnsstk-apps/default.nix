{ lib, stdenv, fetchFromGitHub, cmake, gnsstk }:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnsstk-apps";
  version = "14.0.0";

  src = fetchFromGitHub {
    owner = "SGL-UT";
    repo = "gnsstk-apps";
    rev = "v${finalAttrs.version}";
    hash = "sha256-cq2ZAT3nj7TnB82Rhf72zxBP+k6iSQRFUh99y8YtOTA=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ gnsstk ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_EXT" true)
    (lib.cmakeFeature "CMAKE_CXX_STANDARD" "14")
  ];

  meta = with lib; {
    description = "GNSSTk applications suite";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.lgpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
})
