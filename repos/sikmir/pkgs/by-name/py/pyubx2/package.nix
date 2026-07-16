{
  lib,
  fetchFromGitHub,
  python3Packages,
  pyrtcm,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "pyubx2";
  version = "1.3.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pyubx2";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ibLH/ZL+ExGb3yn39mg4X54J46b+24ze3d0teUTasiY=";
  };

  build-system = with python3Packages; [ setuptools ];

  pythonRelaxDeps = [ "pynmeagps" ];

  dependencies = with python3Packages; [
    pynmeagps
    pyrtcm
  ];

  pythonImportsCheck = [ "pyubx2" ];

  meta = {
    description = "UBX protocol parser and generator";
    homepage = "https://github.com/semuconsulting/pyubx2";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
