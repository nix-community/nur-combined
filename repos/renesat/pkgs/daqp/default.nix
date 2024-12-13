{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:
stdenv.mkDerivation rec {
  pname = "daqp";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "darnstrom";
    repo = "daqp";
    rev = "v${version}";
    hash = "sha256-e2T5+DNMJq4eBhj8F7kKgfGIozFRTuDif3oQ08lIStA=";
  };

  nativeBuildInputs = [cmake];

  meta = with lib; {
    description = "A dual active-set algorithm for convex quadratic programming";
    homepage = "https://github.com/darnstrom/daqp";
    license = licenses.mit;
    maintainers = with maintainers; [renesat];
    inherit (cmake.meta) platforms;
  };
}
