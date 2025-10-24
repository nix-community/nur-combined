{
  python3Packages,
  fetchFromGitHub,
  lib,
}: let
  version = "3.1.0";
in
  python3Packages.buildPythonApplication {
    pname = "claude-code-usage-monitor";
    inherit version;
    format = "pyproject";

    src = fetchFromGitHub {
      owner = "Maciek-roboblog";
      repo = "Claude-Code-Usage-Monitor";
      tag = "v${version}";
      hash = "sha256-v5ooniaN1iVerBW77/00SpghIVE1j8cl2WENcPnS66M=";
    };

    nativeBuildInputs = with python3Packages; [
      setuptools
      wheel
    ];

    propagatedBuildInputs = with python3Packages; [
      numpy
      pydantic
      pydantic-settings
      pyyaml
      pytz
      rich
      tomli
    ];

    doCheck = false;
    pythonImportsCheck = ["claude_monitor"];

    meta = with lib; {
      description = "Real-time Claude Code usage monitor with predictions and warnings";
      homepage = "https://github.com/Maciek-roboblog/Claude-Code-Usage-Monitor";
      license = licenses.mit;
      maintainers = [];
      platforms = platforms.all;
      mainProgram = "claude-monitor";
    };
  }
