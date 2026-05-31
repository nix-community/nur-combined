{
  lib,
  fetchFromGitHub,
  python3Packages,
  pyrtcm,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "pyunigps";
  version = "1.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pyunigps";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UuXtJTzsmjdYuWXt3bqQzj5sZLMfczVnCnDNt+X4lP4=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    pynmeagps
    pyrtcm
  ];

  pythonImportsCheck = [ "pyunigps" ];

  meta = {
    description = "Unicore UNI protocol parser and generator";
    homepage = "https://github.com/semuconsulting/pyunigps";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
