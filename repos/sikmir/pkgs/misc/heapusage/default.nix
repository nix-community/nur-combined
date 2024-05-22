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

  meta = with lib; {
    description = "Light-weight tool for finding heap memory errors";
    inherit (src.meta) homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    mainProgram = "heapusage";
  };
}
