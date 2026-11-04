{
  lib,
  fetchFromGitHub,
  python3Packages,
  ipyfilechooser,
  ipytree,
  whitebox,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "whiteboxgui";
  version = "2.3.0";
  pyproject = true;

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "opengeos";
    repo = "whiteboxgui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KQkqTT8UIVRcfgoLnqA/G37BKW2J6N/b9/uqXeMWMAM=";
  };

  build-system = with python3Packages; [ setuptools_80 ];

  dependencies = with python3Packages; [
    ipyfilechooser
    ipywidgets
    ipytree
    whitebox
  ];

  pythonImportsCheck = [ "whiteboxgui" ];

  meta = {
    description = "An interactive GUI for WhiteboxTools in a Jupyter-based environment";
    homepage = "https://github.com/opengeos/whiteboxgui";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
