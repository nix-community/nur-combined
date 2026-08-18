{ lib
, fetchFromGitHub
, buildPythonApplication
, python3Packages
, poetry
}:
let
  pname = "tokei-pie";
  version = "1.2.0";
in
buildPythonApplication {
  inherit pname version;
  pyproject = true;

  disabled = python3Packages.pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "laixintao";
    repo = "tokei-pie";
    rev = "v${version}";
    hash = "sha256-bVwTWNPtK/bhOE0EkW9SmrcXHwLPz5gqVwOec+WsZGs=";
  };

  build-system = with python3Packages; [ poetry-core ];

  dependencies = with python3Packages; [
    poetry-core
    poetry
    plotly
    packaging
  ];


  nativeBuildInputs = with python3Packages; [
    poetry-core
  ];

  preCheck = ''
    export HOME=$TMPDIR
  '';

  meta = {
    description = "Render tokei's output to interactive sunburst chart";
    homepage = "https://github.com/laixintao/tokei-pie";
    changelog = "https://github.com/laixintao/tokei-pie/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "tokei-pie";
    # maintainers = with lib.maintainers; [ anas ];
    platforms = with lib.platforms; unix ++ windows;
  };
}
