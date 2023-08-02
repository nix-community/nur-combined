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
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "qpsolvers";
    repo = "qpsolvers";
    rev = "v${version}";
    hash = "sha256-GrYAhTWABBvU6rGoHi00jBa7ryjCNgzO/hQBTdSW9cg=";
  };

  nativeBuildInputs = with python3.pkgs; [flit unittestCheckHook];

  propagatedBuildInputs = with python3.pkgs; [
    daqp
    ecos
    numpy
    (
      osqp.overrideAttrs (old: {
        postPatch = ''
          ${old.postPatch}
          sed -i 's/np.int)/int)/g' src/osqp/*.py
        '';
      })
    )
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

    # Test
    quadprog
  ];

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
