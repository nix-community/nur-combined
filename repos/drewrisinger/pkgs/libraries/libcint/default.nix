{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, cmake
, openblas
  # Check Inputs
, python
}:

stdenv.mkDerivation rec {
  pname = "libcint";
  version = "4.0.7";

  src = fetchFromGitHub {
    owner = "sunqm";
    repo = "libcint";
    rev = "v${version}";
    sha256 = "1as3hrwmisr1m93pyzfs5mcakhn3s9iw1z118aypl088l9qlnbpx";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ openblas ];
  cmakeFlags = [
    "-DENABLE_TEST=1"
    "-DQUICK_TEST=1"
    "-DCMAKE_INSTALL_PREFIX=" # ends up double-adding /nix/store/... prefix, this avoids issue
    "-DWITH_F12=1"
    "-DWITH_RANGE_COULOMB=1"
    "-DWITH_COULOMB_ERF=1"
  ];

  doCheck = true;

  checkInputs = [ python.pkgs.numpy ];

  meta = with lib; {
    description = "General GTO integrals for quantum chemistry";
    longDescription = ''
      libcint is an open source library for analytical Gaussian integrals.
      It provides C/Fortran API to evaluate one-electron / two-electron
      integrals for Cartesian / real-spheric / spinor Gaussian type functions.
    '';
    homepage = "http://wiki.sunqm.net/libcint";
    downloadPage = "https://github.com/sunqm/libcint";
    changelog = "https://github.com/sunqm/libcint/releases/tag/v${version}";
    license = licenses.bsd2;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
