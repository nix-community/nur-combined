{
  lib,
  fetchFromGitHub,
  python3Packages,
  pyubx2,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "pyubxutils";
  version = "1.0.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pyubxutils";
    tag = "v${finalAttrs.version}";
    hash = "sha256-k6/7BKzDVQNvjS0JNVJnj7ALHPcq6VwklxpxLhJ/e3M=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    pyserial
    pyubx2
  ];

  pythonImportsCheck = [ "pyubxutils" ];

  meta = {
    description = "Python UBX GNSS device command line utilities";
    homepage = "https://github.com/semuconsulting/pyubxutils";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
