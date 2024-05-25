{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation rec {
  pname = "heapusage";
  version = "2.07";

  src = fetchFromGitHub {
    owner = "d99kris";
    repo = "heapusage";
    rev = "v${version}";
    hash = "sha256-p7Yhx/w1I0+dxD7YH15Eojs4wh337/mZnXBwpiqlt4A=";
  };

  nativeBuildInputs = [ cmake ];

  meta = {
    description = "Light-weight tool for finding heap memory errors";
    inherit (src.meta) homepage;
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    mainProgram = "heapusage";
  };
}
