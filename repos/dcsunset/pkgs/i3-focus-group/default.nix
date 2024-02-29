{ buildPythonApplication
, fetchFromGitHub
, lib
, i3ipc
, setuptools
}:

buildPythonApplication rec {
  pname = "i3-focus-group";
  version = "0.1.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = "i3-focus-group";
    rev = "refs/tags/v${version}";
    hash = "sha256-l/jEg3K0pTKBac5a/GznnjfyuBqX8yrzsOI+uEj7M1I=";
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
