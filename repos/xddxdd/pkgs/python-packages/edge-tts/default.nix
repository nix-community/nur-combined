{
  buildPythonPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
  # Dependencies
  aiohttp,
  certifi,
  srt,
  tabulate,
  typing-extensions,
  setuptools,
}:
buildPythonPackage (finalAttrs: {
  pname = "edge-tts";
  version = "7.2.8";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "rany2";
    repo = "edge-tts";
    tag = finalAttrs.version;
    hash = "sha256-Zjng/7ALTjmDS4ubSFWoBJQ8TNsc2Ijl9V3jSyKifMc=";
  };

  build-system = [ setuptools ];
  dependencies = [
    aiohttp
    certifi
    srt
    tabulate
    typing-extensions
  ];

  pythonImportsCheck = [
    "edge_tts"
    "edge_playback"
  ];

  meta = {
    changelog = "https://github.com/rany2/edge-tts/releases/tag/${finalAttrs.version}";
    mainProgram = "edge-tts";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Use Microsoft Edge's online text-to-speech service from Python WITHOUT needing Microsoft Edge or Windows or an API key";
    homepage = "https://github.com/rany2/edge-tts";
    license = with lib.licenses; [ lgpl3Only ];
  };

  passthru.updateScript = nix-update-script { };
})
