{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  boost,
  eigen,
  pythonSupport ? false,
  python3Packages,
  hpp-centroidal-dynamics,
  py-hpp-centroidal-dynamics,
  ndcurves,
  py-ndcurves,
  glpk,
}:
let
  python = python3Packages.python.withPackages (p: [
    p.boost
    p.eigenpy
    py-ndcurves
    py-hpp-centroidal-dynamics
  ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "hpp-bezier-com-traj";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "humanoid-path-planner";
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    hash = "sha256-kzSt+83coQyAn9BsX6waSOFO73P1ng+OBKvWoaibikk=";
  };

  outputs = [
    "dev"
    "out"
  ];

  strictDeps = true;

  nativeBuildInputs = [ cmake ];

  propagatedBuildInputs = [
    boost
    eigen
    ndcurves
    glpk
    hpp-centroidal-dynamics
  ] ++ lib.optionals pythonSupport [ python ];

  cmakeFlags = [
    "-DUSE_GLPK=ON"
    (lib.cmakeBool "BUILD_PYTHON_INTERFACE" pythonSupport)
  ];

  doCheck = true;

  pythonImportsCheck = lib.optionals (!pythonSupport) [ "hpp_bezier_com_traj" ];

  meta = {
    description = "Multi contact trajectory generation for the COM using Bezier curves";
    homepage = "https://github.com/humanoid-path-planner/hpp-bezier-com-traj";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.nim65s ];
  };
})
