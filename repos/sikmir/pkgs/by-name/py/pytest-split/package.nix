{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "pytest-split";
  version = "0.11.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jerry-git";
    repo = "pytest-split";
    tag = finalAttrs.version;
    hash = "sha256-shj+04sqL3MmBmHw1c3kP+aX2QgzpAWJOsz9hSs9B7A=";
  };

  build-system = with python3Packages; [ poetry-core ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    pytest-cov-stub
  ];

  meta = {
    description = "Pytest plugin which splits the test suite to equally sized sub suites based on test execution time";
    homepage = "https://github.com/jerry-git/pytest-split";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
