{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:
stdenv.mkDerivation rec {
  pname = "daqp";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "darnstrom";
    repo = "daqp";
    rev = "v${version}";
    hash = "sha256-s22LVnK1qGjIpat21eXYF/Io49IYbWf1y+VUbYuPZaY=";
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
