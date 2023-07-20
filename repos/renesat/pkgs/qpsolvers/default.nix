{
  lib,
  stdenv,
  python3,
  fetchFromGitHub,
  daqp,
}:
python3.pkgs.buildPythonPackage rec {
  pname = "qpsolvers";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "qpsolvers";
    repo = "qpsolvers";
    rev = "v${version}";
    hash = "sha256-GrYAhTWABBvU6rGoHi00jBa7ryjCNgzO/hQBTdSW9cg=";
  };

  nativeBuildInputs = with python3.pkgs; [flit];

  propagatedBuildInputs = with python3.pkgs; [
    daqp
    ecos
    numpy
    osqp
    scipy
    (scs.overrideAttrs (
      old: {
        src = fetchFromGitHub {
          owner = "bodono";
          repo = "scs-python";
          rev = "3.2.3";
          hash = "sha256-/5yGvZy3luGQkbYcsb/6TZLYou91lpA3UKONviMVpuM=";
          fetchSubmodules = true;
        };
      }
    ))
  ];

  setuptoolsCheckPhase = ":";

  buildPhase = ''
    flit build
  '';

  meta = with lib; {
    description = "Quadratic programming solvers in Python with a unified API";
    homepage = "https://github.com/qpsolvers/qpsolvers";
    license = licenses.lgpl3;
    maintainers = with maintainers; [renesat];
  };
}
