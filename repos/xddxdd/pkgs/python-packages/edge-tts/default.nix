{
  lib,
  sources,
  buildPythonPackage,
  python3Packages,
  # Dependencies
  aiohttp,
  certifi,
  srt,
  tabulate,
  typing-extensions,
}:
buildPythonPackage rec {
  inherit (sources.edge-tts) pname version src;

  build-system = with python3Packages; [ setuptools ];
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
    mainProgram = "edge-tts";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Use Microsoft Edge's online text-to-speech service from Python WITHOUT needing Microsoft Edge or Windows or an API key";
    homepage = "https://github.com/rany2/edge-tts";
    license = with lib.licenses; [ lgpl3Only ];
  };
}
