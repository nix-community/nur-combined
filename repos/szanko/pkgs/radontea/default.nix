{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonPackage rec {
  pname = "radontea";
  version = "0.5.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "RI-imaging";
    repo = "radontea";
    rev = version;
    hash = "sha256-DpXNcE8dHtlO0aVyvyqWqyPFL78DIVHySLZ0d2c48hk=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.setuptools-scm
    python3.pkgs.wheel
  ];

  dependencies = with python3.pkgs; [
    numpy
    scipy
  ];

  pythonImportsCheck = [
    "radontea"
  ];

  meta = {
    description = "Python library for tomographic image reconstruction";
    homepage = "https://github.com/RI-imaging/radontea";
    changelog = "https://github.com/RI-imaging/radontea/blob/${src.rev}/CHANGELOG";
    license = lib.licenses.bsd3;
    maintainers =
      let m = lib.maintainers or {};
      in lib.optionals (m ? szanko) [ m.szanko ];
  };
}
