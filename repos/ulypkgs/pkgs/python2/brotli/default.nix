{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "brotli";
  version = "1.0.9";

  # PyPI doesn't contain tests so let's use GitHub
  src = fetchFromGitHub {
    owner = "google";
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    hash = "sha256-8CtCUt1UbK+QAv8Kk7tqesnBHiNvlNvjMQSfFHpOt+U=";
    # for some reason, the test data isn't captured in releases, force a git checkout
    deepClone = true;
  };

  dontConfigure = true;

  checkInputs = [
    pytestCheckHook
  ];

  pytestFlagsArray = [
    "python/tests"
  ];

  meta = with lib; {
    homepage = "https://github.com/google/brotli";
    description = "Generic-purpose lossless compression algorithm";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
})
