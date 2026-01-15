{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "pyrtcm";
  version = "1.1.10";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pyrtcm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NZmzIMOS3BLkSC1hf2tV770qPpgBQ8uS/VvVh+e5AAs=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [ pynmeagps ];

  pythonImportsCheck = [ "pyrtcm" ];

  meta = {
    description = "RTCM3 protocol parser";
    homepage = "https://github.com/semuconsulting/pyrtcm";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
