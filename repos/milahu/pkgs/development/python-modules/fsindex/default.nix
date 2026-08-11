{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "fsindex";
  version = "0-unstable-2026-08-04";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "milahu";
    repo = "fsindex";
    rev = "147da0803fee74033d88df032814077f09144394";
    hash = "sha256-C8rD/SRH+5UJydn9ufYDXRknq1HlU0ijBq/m1WVy+js=";
  };

  build-system = [
    python3.pkgs.setuptools
  ];

  dependencies = with python3.pkgs; [
    psutil
  ];

  pythonImportsCheck = [
    "fsindex"
  ];

  meta = {
    description = "Filesystem indexer with SQLite storage";
    homepage = "https://github.com/milahu/fsindex";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "fsindex";
  };
})
