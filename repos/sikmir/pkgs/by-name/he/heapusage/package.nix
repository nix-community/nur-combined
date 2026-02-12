{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "heapusage";
  version = "2.17";

  src = fetchFromGitHub {
    owner = "d99kris";
    repo = "heapusage";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+Q6fOp5eT0bDN6ojQOrto1lgdC4VIQlhc2iEsfIBFSs=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.10")
  ];

  meta = {
    description = "Light-weight tool for finding heap memory errors";
    homepage = "https://github.com/d99kris/heapusage";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    mainProgram = "heapusage";
  };
})
