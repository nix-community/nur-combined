{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "ipyfilechooser";
  version = "0.6.0";
  pyproject = true;

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "crahan";
    repo = "ipyfilechooser";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9MM5BJ2KGWoZMXbcHx9U7XRLKURZ42aTY7avQ+dYUvs=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [ ipywidgets ];

  pythonImportsCheck = [ "ipyfilechooser" ];

  meta = {
    description = "Python file chooser widget for use in Jupyter/IPython in conjunction with ipywidgets";
    homepage = "https://github.com/crahan/ipyfilechooser";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
