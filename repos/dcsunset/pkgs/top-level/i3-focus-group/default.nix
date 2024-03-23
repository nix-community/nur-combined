{ python3Packages, fetchFromGitHub, lib }:

let
  inherit (python3Packages)
    buildPythonApplication
    i3ipc
    setuptools;
in
buildPythonApplication rec {
  pname = "i3-focus-group";
  version = "0.1.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = "i3-focus-group";
    rev = "refs/tags/v${version}";
    hash = "sha256-dduvTCh8N8p5BJ+pNAvsdqCqIoj197lCSx28CnfNmCI=";
  };

  nativeBuildInputs = [
    setuptools
  ];

  propagatedBuildInputs = [ i3ipc ];

  pythonImportsCheck = [ "i3_focus_group.main" ];

  meta = with lib; {
    description = "Create a group for i3/sway containers to easily switch focus between";
    homepage = "https://github.com/DCsunset/i3-focus-group";
    license = licenses.agpl3Only;
    mainProgram = "i3-focus-group";
  };
}
