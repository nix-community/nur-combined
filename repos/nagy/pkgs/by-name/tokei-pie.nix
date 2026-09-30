{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "tokei-pie";
  version = "1.2.2";
  pyproject = true;

  src = fetchPypi {
    pname = "tokei_pie";
    inherit version;
    hash = "sha256-xglHgQCu7PZ45D3PSHodxCkez5d1gRh1WLcrGaGXcVw=";
  };

  nativeBuildInputs = [ python3.pkgs.poetry-core ];

  propagatedBuildInputs = [
    python3.pkgs.packaging
    python3.pkgs.plotly
  ];

  pythonImportsCheck = [ "tokei_pie" ];

  pythonRelaxDeps = [ "plotly" ];

  meta = {
    description = "Draw a pie chart for tokei output";
    homepage = "https://pypi.org/project/tokei-pie/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "tokei-pie";
  };
}
