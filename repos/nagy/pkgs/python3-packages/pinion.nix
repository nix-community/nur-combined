{
  lib,
  fetchPypi,
  buildPythonPackage,
  setuptools,
  click,
  inkscape,
  kicad,
  makeWrapper,
  pcbdraw,
  python,
  ruamel-yaml,
  versioneer,
}:

buildPythonPackage rec {
  pname = "pinion";
  version = "0.4.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-YWjH0Ie1ffEZ1jgLqhsiLtcfU87p9rJanMlhUN9PLj4=";
  };

  build-system = [
    setuptools
    versioneer
  ];

  dependencies = [
    click
    pcbdraw
    ruamel-yaml
  ];

  pythonImportsCheck = [
    "pinion"
  ];

  nativeBuildInputs = [ makeWrapper ];

  # pinion imports `pcbnew` (KiCad's Python bindings) at runtime; those live in
  # kicad's site-packages, not in our Python environment. It also shells out to
  # inkscape for SVG to PNG conversion.
  postFixup = ''
    wrapProgram $out/bin/pinion \
      --prefix PATH : ${lib.makeBinPath [ inkscape ]} \
      --prefix PYTHONPATH : ${kicad}/${python.sitePackages}
  '';

  meta = {
    description = "Create interactive pinout diagrams for KiCAD PCBs";
    homepage = "https://github.com/yaqwsx/Pinion";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "pinion";
  };
}
