{ buildPythonApplication
, fetchFromGitHub
, lib
, i3ipc
, setuptools
}:

buildPythonApplication rec {
  pname = "i3-focus-group";
  version = "0.1.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = "i3-focus-group";
    rev = "refs/tags/v${version}";
    hash = "sha256-o5aLPl4baTRY9uTwNbuaVW3eqA+VFFH08nhhKmHpHQ0=";
  };

  nativeBuildInputs = [
    setuptools
  ];

  propagatedBuildInputs = [ i3ipc ];

  pythonImportsCheck = [ "i3_focus_group.main" ];

  meta = with lib; {
    description = "Create a group for i3/sway containers to easily switch focus between";
    homepage = "https://github.com/DCsunset/i3-focus-group";
    license = licenses.agpl3;
    mainProgram = "i3-focus-group";
  };
}
