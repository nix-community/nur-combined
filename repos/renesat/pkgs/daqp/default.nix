{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:
stdenv.mkDerivation rec {
  pname = "daqp";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "darnstrom";
    repo = "daqp";
    rev = "v${version}";
    hash = "sha256-9sPYyd8J78HKDxbwkogu8tW38rgYIctEWqrriqJKy0M=";
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
