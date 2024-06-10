{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ndcurves,
  pythonSupport ? false,
  python3Packages,
}:

stdenv.mkDerivation rec {
  pname = "multicontact-api";
  version = "3.0.3";

  src = fetchFromGitHub {
    owner = "loco-3d";
    repo = "multicontact-api";
    rev = "v${version}";
    hash = "sha256-qZ9PyF6PNAl4d7QBogyUPHZ2/F8sEVxKH2jX5TxVnc0=";
    fetchSubmodules = true;
  };

  outputs = [
    "dev"
    "out"
  ];

  nativeBuildInputs = [ cmake ];

  propagatedBuildInputs =
    lib.optionals (!pythonSupport) [ ndcurves ]
    ++ lib.optionals (pythonSupport) [ python3Packages.ndcurves ];

  cmakeFlags = [ (lib.cmakeBool "BUILD_PYTHON_INTERFACE" pythonSupport) ];

  doCheck = true;

  pythonImportsCheck = lib.optionals (!pythonSupport) [ "multicontact_api" ];

  meta = with lib; {
    description = "This package install a python module used to define, store and use ContactSequence objects";
    homepage = "https://github.com/loco-3d/multicontact-api";
    license = licenses.bsd2;
    maintainers = with maintainers; [ nim65s ];
  };
}
