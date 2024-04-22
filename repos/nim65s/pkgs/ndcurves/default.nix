{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  jrl-cmakemodules,
  pinocchio,
  pythonSupport ? false,
  python3Packages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ndcurves";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "loco-3d";
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    hash = "sha256-XJ3VSSGKSJ+x3jc4408PGHTYg3nC7o/EeFnbKBELefs=";
  };

  outputs = [
    "dev"
    "out"
  ];

  strictDeps = true;

  nativeBuildInputs = [ cmake ];

  propagatedBuildInputs =
    [ jrl-cmakemodules ]
    ++ lib.optionals (!pythonSupport) [ pinocchio ]
    ++ lib.optionals pythonSupport [
      python3Packages.eigenpy
      python3Packages.pinocchio
    ];

  cmakeFlags = [ (lib.cmakeBool "BUILD_PYTHON_INTERFACE" pythonSupport) ];

  doCheck = true;

  pythonImportsCheck = lib.optionals (!pythonSupport) [ "ndcurves" ];

  meta = with lib; {
    description = "Library for creating smooth cubic splines";
    homepage = "https://github.com/loco-3d/ndcurves";
    license = licenses.bsd2;
    maintainers = with maintainers; [ nim65s ];
  };
})
