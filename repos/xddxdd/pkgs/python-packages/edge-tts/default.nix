{
  lib,
  sources,
  buildPythonPackage,
  # Dependencies
  aiohttp,
  certifi,
  srt,
  tabulate,
  typing-extensions,
}:
buildPythonPackage rec {
  inherit (sources.edge-tts) pname version src;

  propagatedBuildInputs = [
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
    homepage = "https://pypi.org/project/edge-tts/";
    license = with lib.licenses; [ lgpl3Only ];
  };
}
