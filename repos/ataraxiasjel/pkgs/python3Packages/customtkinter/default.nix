{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  darkdetect,
  packaging,
  nix-update-script,
}:
buildPythonPackage rec {
  pname = "customtkinter";
  version = "5.2.2";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-/Y2zuvqWHJgu5gMNuoC0wuJYWGMHVrUTmG2xkRPY0gc=";
  };

  buildInputs = [ setuptools ];
  propagatedBuildInputs = [
    darkdetect
    packaging
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    changelog = "https://github.com/TomSchimansky/CustomTkinter/releases/tag/${version}";
    homepage = "https://github.com/TomSchimansky/CustomTkinter";
    description = "A modern and customizable python UI-library based on Tkinter";
    license = licenses.mit;
    maintainers = with maintainers; [ ataraxiasjel ];
  };
}
