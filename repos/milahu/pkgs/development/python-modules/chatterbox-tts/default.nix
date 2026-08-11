{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  conformer,
  diffusers,
  librosa,
  numpy,
  resemble-perth,
  s3tokenizer,
  safetensors,
  torch,
  torchaudio,
  transformers,
}:

buildPythonPackage (finalAttrs: {
  pname = "chatterbox-tts";
  version = "0.1.7"; # Mar 26, 2026
  pyproject = true;

  src = fetchFromGitHub {
    owner = "resemble-ai";
    repo = "chatterbox";
    # fixme: no git tags
    # tag = "v${finalAttrs.version}";
    rev = "59bc590b3cad826e5d5987745bf6844627a21ad5"; # Mar 26, 2026
    hash = "sha256-zWH9/A+nckUPaZUlWXy2s0RtAlUhSfVk42P+cKdgzmY=";
  };

  postPatch = ''
    # unpin dependencies
    sed -i '/^dependencies = \[/,/^]/d' pyproject.toml
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    conformer
    diffusers
    librosa
    numpy
    resemble-perth
    s3tokenizer
    safetensors
    torch
    torchaudio
    transformers
  ];

  pythonImportsCheck = [
    # FIXME RuntimeError: cannot cache function '__o_fold': no locator available for file
    # "chatterbox"
  ];

  checkPhase = ":";

  meta = {
    description = "SoTA open-source TTS";
    homepage = "https://github.com/resemble-ai/chatterbox";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
})
