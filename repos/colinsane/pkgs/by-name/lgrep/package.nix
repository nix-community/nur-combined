{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication rec {
  pname = "lgrep";
  version = "0.1.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "nuxion";
    repo = "lgrep";
    rev = "v${version}";
    hash = "sha256-VWBh9vyFCSVG1ZOsqRTd7a7JCzXczG1h14NeKgFiIso=";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    typer
    rich
    fastembed
    chromadb
    watchdog
    pathspec
    tomli
    tomli-w
    numpy
    chardet
  ];

  pythonImportsCheck = [ "lgrep" ];

  meta = {
    description = "Local-first semantic search CLI tool for code and text files";
    homepage = "https://github.com/nuxion/lgrep";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ colinsane ];
    mainProgram = "lgrep";
  };
}
