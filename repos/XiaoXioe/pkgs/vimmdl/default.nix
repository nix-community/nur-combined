{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication {
  pname = "vimmdl";
  version = "0-unstable-2025-05-21";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "devvratmiglani";
    repo = "Vimmdl";
    rev = "f4223d196691bd303e3b577e1173540ffe565de4";
    hash = "sha256-NmvRzSgFz12S1ffOH9vXCbyZhusOzUt4XEY7v+oj3FY=";
  };

  nativeBuildInputs = [
    python3.pkgs.pythonRelaxDepsHook
  ];

  pythonRemoveDeps = [
    "bs4"
    "setuptools"
  ];

  build-system = [
    python3.pkgs.setuptools
  ];

  dependencies = with python3.pkgs; [
    beautifulsoup4
    certifi
    click
    colorama
    requests
    tabulate
    truststore
  ];

  pythonImportsCheck = [
    "vm"
  ];

  meta = {
    description = "Command Line tool to search and download roms from Vimm's Lair";
    homepage = "https://github.com/devvratmiglani/Vimmdl";
    license = lib.licenses.mit;
    mainProgram = "vm";
  };
}
