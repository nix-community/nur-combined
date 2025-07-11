{
  lib,
  fetchFromGitHub,
  python312Packages,
  s2sphere,
}:

python312Packages.buildPythonApplication rec {
  pname = "py-staticmaps";
  version = "0.5.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "flopp";
    repo = "py-staticmaps";
    tag = "v${version}";
    hash = "sha256-TWLPCM1tsWiRCLDhowC/uQrDUujNO3FuDgnUQXMcTm0=";
  };

  postPatch = ''
    sed -i '/^slugify/d' requirements.txt
  '';

  build-system = with python312Packages; [ setuptools ];

  dependencies = with python312Packages; [
    appdirs
    geographiclib
    pillow
    pycairo
    python-slugify
    requests
    s2sphere
    svgwrite
    types-requests
  ];

  nativeCheckInputs = with python312Packages; [ pytestCheckHook ];

  meta = {
    description = "A python module to create static map images with markers, geodesic lines, etc";
    homepage = "https://github.com/flopp/py-staticmaps";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
