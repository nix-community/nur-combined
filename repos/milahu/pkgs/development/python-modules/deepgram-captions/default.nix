{
  lib,
  python,
  fetchFromGitHub,
}:

python.pkgs.buildPythonApplication (finalAttrs: {
  pname = "deepgram-captions";
  version = "2.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "deepgram";
    repo = "deepgram-python-captions";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7d6rCdm0GEF5QASTasFTbAJvUaaqgBF9HNYKMPwfre0=";
  };

  build-system = [
    python.pkgs.setuptools
    python.pkgs.wheel
  ];

  optional-dependencies = with python.pkgs; {
    dev = [
      mypy
      pytest
      ruff
    ];
  };

  pythonImportsCheck = [
    "deepgram_captions"
  ];

  meta = {
    description = "This package is the Python implementation of Deepgram's WebVTT and SRT formatting. Given a transcription, this package can return a valid string to store as WebVTT or SRT caption files";
    homepage = "https://github.com/deepgram/deepgram-python-captions";
    changelog = "https://github.com/deepgram/deepgram-python-captions/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "deepgram-captions";
  };
})
