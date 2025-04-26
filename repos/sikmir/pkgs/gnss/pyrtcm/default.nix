{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "pyrtcm";
  version = "1.1.6";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pyrtcm";
    tag = "v${version}";
    hash = "sha256-PqNigqolC44DWZiSQDtdlt4RVUfyKTDznbHu1AvrwzQ=";
  };

  build-system = with python3Packages; [ setuptools ];

  pythonImportsCheck = [ "pyrtcm" ];

  meta = {
    description = "RTCM3 protocol parser";
    homepage = "https://github.com/semuconsulting/pyrtcm";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
