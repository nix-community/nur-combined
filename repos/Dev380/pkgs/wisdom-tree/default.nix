{
  lib,
  pkgs,
  fetchFromGitHub,
  ...
}:
let
  pythonPackages = pkgs.python313Packages;
in
pythonPackages.buildPythonApplication rec {
  pname = "wisdom-tree";
  version = "0.0.20";

  src = fetchFromGitHub {
    owner = "HACKER097";
    repo = "wisdom-tree";
    rev = "refs/tags/v${version}";
    hash = "sha256-PnOzQtiG1y7D4WTiUJMdvqEtdhnFVbJCIREWmuSbsIs=";
  };

  pyproject = true;
  build-system = with pythonPackages; [
    setuptools
    wheel
  ];

  propagatedBuildInputs = with pythonPackages; [
    python-vlc
    pytube
  ];
  meta = {
    description = "TUI concentration app with features like pomodoro timer, YouTube music player, Lo-fi radio.";
    homepage = "https://github.com/Hacker097/wisdom-tree";
    license = lib.licenses.mit;
    mainProgram = "wisdom-tree";
  };
}
