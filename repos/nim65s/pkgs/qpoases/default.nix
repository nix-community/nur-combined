{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qpoases";
  version = "3.2.1";

  src = fetchFromGitHub {
    owner = "coin-or";
    repo = finalAttrs.pname;
    rev = "releases/${finalAttrs.version}";
    sha256 = "sha256-NWKwKYdXJD8lGorhTFWJmYeIhSCO00GHiYx+zHEJk0M=";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "Open-source C++ implementation of the recently proposed online active set strategy";
    homepage = "https://github.com/coin-or/qpOASES";
    license = licenses.lgpl21;
    platforms = platforms.unix;
    maintainers = with maintainers; [ nim65s ];
  };
})
