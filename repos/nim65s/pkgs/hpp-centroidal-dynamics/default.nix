{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  boost,
  cddlib,
  eigen,
  jrl-cmakemodules,
  pythonSupport ? false,
  python3Packages,
  qpoases,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "hpp-centroidal-dynamics";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "humanoid-path-planner";
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    hash = "sha256-oy9FX4V9k0hNOfYLQsvXBx21eIBht0lWcuiVuXf6zk4=";
  };

  strictDeps = true;

  nativeBuildInputs = [ cmake ];

  propagatedBuildInputs =
    [
      boost
      cddlib
      eigen
      jrl-cmakemodules
      qpoases
    ]
    ++ lib.optionals pythonSupport [
      python3Packages.boost
      python3Packages.eigenpy
    ];

  cmakeFlags = [ (lib.cmakeBool "BUILD_PYTHON_INTERFACE" pythonSupport) ];

  doCheck = true;

  pythonImportsCheck = lib.optionals (!pythonSupport) [ "hpp_centroidal_dynamics" ];

  meta = {
    description = "Utility classes to check the (robust) equilibrium of a system in contact with the environment.";
    homepage = "https://github.com/humanoid-path-planner/hpp-centroidal-dynamics";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.nim65s ];
  };
})
