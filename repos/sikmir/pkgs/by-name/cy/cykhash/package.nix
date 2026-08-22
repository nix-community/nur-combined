{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "cykhash";
  version = "2.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "realead";
    repo = "cykhash";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Bw85RJudoGNa2GrEwxGaln93T7c2YyRakWZcMJAJwUU=";
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

  pytestFlags = [ "tests/unit_tests" ];

  meta = {
    description = "cython wrapper for khash";
    homepage = "https://github.com/realead/cykhash";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
