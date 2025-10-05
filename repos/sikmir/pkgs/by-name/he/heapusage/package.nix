{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "heapusage";
  version = "2.07";

  src = fetchFromGitHub {
    owner = "d99kris";
    repo = "heapusage";
    tag = "v${finalAttrs.version}";
    hash = "sha256-p7Yhx/w1I0+dxD7YH15Eojs4wh337/mZnXBwpiqlt4A=";
  };

  nativeBuildInputs = [ cmake ];

  meta = {
    description = "Light-weight tool for finding heap memory errors";
    homepage = "https://github.com/d99kris/heapusage";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    mainProgram = "heapusage";
  };
})
