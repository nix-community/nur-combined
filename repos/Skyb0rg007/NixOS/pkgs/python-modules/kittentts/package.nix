{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  huggingface-hub,
  misaki,
  num2words,
  numpy,
  onnxruntime,
  phonemizer,
  soundfile,
  spacy,
  nix-update-script,
}:
buildPythonPackage (finalAttrs: {
  pname = "kittentts";
  version = "0.8.1";
  __structuredAttrs = true;
  pyproject = true;

  src = fetchFromGitHub {
    owner = "KittenML";
    repo = "KittenTTS";
    tag = finalAttrs.version;
    hash = "sha256-X0TQP2jF5hTi045U5ggzISRsQD3e8ri+0rF7mXkbEdQ=";
  };

  build-system = [ setuptools ];

  dependencies = [
    huggingface-hub
    misaki
    num2words
    numpy
    onnxruntime
    phonemizer
    soundfile
    spacy
  ]
  ++ misaki.optional-dependencies.en;

  # Only locates a bundled espeak-ng; nixpkgs' phonemizer uses the store's.
  pythonRemoveDeps = [ "espeakng_loader" ];

  pythonImportsCheck = [ "kittentts" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Ultra-lightweight ONNX text-to-speech model";
    homepage = "https://github.com/KittenML/KittenTTS";
    changelog = "https://github.com/KittenML/KittenTTS/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
