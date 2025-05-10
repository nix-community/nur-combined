{
  lib,
  fetchFromGitHub,
  python3Packages,
  pyrtcm,
}:

python3Packages.buildPythonPackage rec {
  pname = "pyubx2";
  version = "1.2.52";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pyubx2";
    tag = "v${version}";
    hash = "sha256-qlVNI61iAujUE+wywMF92CWDCpkffcXHKnHQPX8JRjo=";
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
}
