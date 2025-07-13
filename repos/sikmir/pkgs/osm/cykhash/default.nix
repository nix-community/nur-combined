{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage {
  pname = "cykhash";
  version = "2.0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "realead";
    repo = "cykhash";
    rev = "99db6d2075b1f33177ed034e0c873d58190658ae";
    hash = "sha256-R6a19oExRVHSnfeEM5XsD77BPEWpC0BeNdep12YffN8=";
  };

  build-system = with python3Packages; [
    setuptools
    cython
  ];

  nativeCheckInputs = with python3Packages; [
    numpy
    pytestCheckHook
  ];

  doCheck = false;

  pytestFlagsArray = [ "tests/unit_tests" ];

  meta = {
    description = "cython wrapper for khash";
    homepage = "https://github.com/realead/cykhash";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
