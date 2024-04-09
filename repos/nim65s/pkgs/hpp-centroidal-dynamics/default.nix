{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  boost,
  cddlib,
  eigen,
  pythonSupport ? false,
  python3Packages,
  qpoases,
}:
let
  python = python3Packages.python.withPackages (p: [
    p.boost
    p.eigenpy
  ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "hpp-centroidal-dynamics";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "humanoid-path-planner";
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-En99yno9xC1ItDJiRpfujEmvPazMDlzPJQZlMiDWG2c=";
  };

  outputs = [
    "dev"
    "out"
  ];

  strictDeps = true;

  nativeBuildInputs = [ cmake ];

  propagatedBuildInputs = [
    boost
    cddlib
    eigen
    qpoases
  ] ++ lib.optionals pythonSupport [ python ];

  cmakeFlags = lib.optionals (!pythonSupport) [ "-DBUILD_PYTHON_INTERFACE=OFF" ];

  doCheck = true;

  pythonImportsCheck = lib.optionals (!pythonSupport) [ "hpp_centroidal_dynamics" ];

  meta = {
    description = "Utility classes to check the (robust) equilibrium of a system in contact with the environment.";
    homepage = "https://github.com/humanoid-path-planner/hpp-centroidal-dynamics";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.nim65s ];
  };
})
