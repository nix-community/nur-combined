{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "tokei-pie";
  version = "1.2.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-uVRVBtsiALyX3iE3Dv3NaMXEFHFR0UrdTP/DgXusXeI=";
  };

  nativeBuildInputs = [ python3.pkgs.poetry-core ];

  propagatedBuildInputs = [
    python3.pkgs.packaging
    python3.pkgs.plotly
  ];

  pythonImportsCheck = [ "tokei_pie" ];

  meta = {
    description = "Draw a pie chart for tokei output";
    homepage = "https://pypi.org/project/tokei-pie/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "tokei-pie";
  };
}
