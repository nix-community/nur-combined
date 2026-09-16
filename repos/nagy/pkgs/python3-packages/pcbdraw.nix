{
  lib,
  fetchPypi,
  buildPythonPackage,
  setuptools,
  click,
  kicad,
  lxml,
  inkscape,
  makeWrapper,
  mistune,
  numpy,
  pybars3,
  pillow,
  pyyaml,
  python,
  svgpathtools,
  versioneer,
  wxpython,
}:

buildPythonPackage rec {
  pname = "pcbdraw";
  version = "1.2.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-3EfUHmqWRd7PnVO1bYvPmOmG9N7Raj0SLHsubnbrpAM=";
  };

  build-system = [
    setuptools
    versioneer
  ];

  dependencies = [
    click
    lxml
    mistune
    numpy
    pybars3
    pillow
    pyyaml
    pyyaml
    svgpathtools
    wxpython
  ];

  pythonRelaxDeps = [
    "svgpathtools"
  ];

  pythonImportsCheck = [
    "pcbdraw"
  ];

  nativeBuildInputs = [ makeWrapper ];

  # pcbdraw's plot module imports `pcbnew` (KiCad's Python bindings) at
  # runtime; those live in kicad's site-packages, not in our Python environment.
  # Inkscape converts SVG to PNG during plotting.
  postFixup = ''
    wrapProgram $out/bin/pcbdraw \
      --prefix PATH : ${lib.makeBinPath [ inkscape ]} \
      --prefix PYTHONPATH : ${kicad}/${python.sitePackages}
  '';

  meta = {
    description = "Utility to produce nice looking drawings of KiCAD boards";
    homepage = "https://github.com/yaqwsx/PcbDraw";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "pcbdraw";
  };
}
