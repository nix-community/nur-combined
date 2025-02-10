{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "local-attention";
  version = "1.10.0";
  pyproject = true;

  src = fetchPypi {
    pname = "local_attention";
    inherit version;
    hash = "sha256-j8OEaAYpTPpIr7p+xg4kB/hJ5hCWOMH6FH/o+sEvtt8=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = with python3.pkgs; [
    einops
    torch
  ];

  doCheck = false;

  preBuild = ''
    substituteInPlace setup.py \
      --replace-fail "'pytest-runner'," ""
  '';

  pythonImportsCheck = [
    "local_attention"
  ];

  meta = {
    description = "Local attention, window with lookback, for language modeling";
    homepage = "https://pypi.org/project/local-attention";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "local-attention";
  };
}
