{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "roentgen-icons";
  version = "0.12.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "enzet";
    repo = "Roentgen";
    tag = "v${finalAttrs.version}";
    hash = "sha256-b76QqThVLXiIS02adciOg3lfm2VeMYv6x+rIEEE1N8o=";
  };

  build-system = with python3Packages; [ hatchling ];

  pythonRelaxDeps = true;

  dependencies = with python3Packages; [
    colour
    lxml
    requests
    svgpathtools
    svgwrite
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = {
    description = "Set of monochrome 14 × 14 px pixel-aligned map icons";
    homepage = "https://github.com/enzet/Roentgen";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
