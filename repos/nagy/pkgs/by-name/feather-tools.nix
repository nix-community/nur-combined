{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "feather-tools";
  version = "1.1.0";
  pyproject = true;

  src = fetchPypi {
    pname = "feather_tools";
    inherit version;
    hash = "sha256-qSyGYhZjfbUIUt7T7lj+MZEhoa2Lbxou5LiqQcA5lMs=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = [
    python3.pkgs.pandas
    python3.pkgs.pyarrow
  ];

  optional-dependencies = {
    test = [
      python3.pkgs.pytest
    ];
  };

  pythonImportsCheck = [
    "feather_tools"
  ];

  meta = {
    description = "Scripts to use for pyarrow feather files in a Linux terminal window";
    homepage = "https://pypi.org/project/feather-tools";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
