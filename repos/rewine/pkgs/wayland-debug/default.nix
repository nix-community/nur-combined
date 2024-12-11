{ lib
, fetchFromGitHub
, fetchpatch
, python3
}:

python3.pkgs.buildPythonApplication rec {
  pname = "wayland-debug";
  version = "0-unstable-2024-12-11";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "wmww";
    repo = "wayland-debug";
    rev = "98c04c4e1bbfb3bf1fa8de167283e8398d3e29e7";
    hash = "sha256-owE+ISyQBphayaJrdxs/wT5F2FluzVXySQmfC5B1SpI=";
  };

  #pythonRelaxDeps = [
  #  "textual"
  #];

  #build-system = with python3.pkgs; [
  #  poetry-core
  #];

  nativeBuildInputs = with python3.pkgs; [
  ];

  dependencies = with python3.pkgs; [
  ];

  #pythonImportsCheck = [
  #  "rich_cli"
  #];

  meta = {
    description = "Command line tool to help debug Wayland clients and servers";
    homepage = "https://github.com/wmww/wayland-debug";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ rewine ];
    mainProgram = "rich";
  };
}

