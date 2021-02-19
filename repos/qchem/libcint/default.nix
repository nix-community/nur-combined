{ lib, stdenv, fetchFromGitHub, cmake
, openblas, python
} :
let
  version = "3.0.15";

in stdenv.mkDerivation {
  pname = "libcint";
  inherit version;

  src = fetchFromGitHub {
    owner = "sunqm";
    repo = "libcint";
    rev = "v${version}";
    sha256 = "18nq6nyprng2dblg37cjbp2jnvqfvn9rrsaaj1jxjgvww49ziv6w";
  };

  nativeBuildInputs = [ cmake python python.pkgs.numpy ];
  buildInputs = [ openblas ];

  doCheck = true;

  # somehow gets /nix/store/.. twice
  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX:PATH=/"
    "-DENABLE_TEST=0"
    "-DWITH_RANGE_COULOMB=1"
    "-DI8=0"
  ];

  meta = with lib; {
    description = "Open source library for analytical Gaussian integrals";
    homepage = https://github.com/sunqm/libcint;
    license = licenses.bsd2;
    maintainers = [ maintainers.markuskowa ];
    platforms = platforms.linux;
  };
}

