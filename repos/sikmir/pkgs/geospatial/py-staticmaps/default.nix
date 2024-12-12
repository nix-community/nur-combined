{
  lib,
  fetchFromGitHub,
  python3Packages,
  s2sphere,
}:

python3Packages.buildPythonApplication rec {
  pname = "py-staticmaps";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "flopp";
    repo = "py-staticmaps";
    tag = "v${version}";
    hash = "sha256-vW457HbdDDhfz8hsvEN3/HJmIHKdrRDVNuhSpZXoZ78=";
  };

  dependencies = with python3Packages; [
    appdirs
    geographiclib
    pillow
    pycairo
    python-slugify
    requests
    s2sphere
    svgwrite
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = {
    description = "A python module to create static map images with markers, geodesic lines, etc";
    homepage = "https://github.com/flopp/py-staticmaps";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
