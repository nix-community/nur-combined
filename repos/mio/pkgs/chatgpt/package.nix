{
  lib,
  fetchurl,
  makePakeApp,
}:

makePakeApp {
  pname = "chatgpt";
  appName = "ChatGPT";
  url = "https://chatgpt.com/";
  icon = fetchurl {
    url = "https://upload.wikimedia.org/wikipedia/commons/thumb/6/66/OpenAI_logo_2025_%28symbol%29.svg/1280px-OpenAI_logo_2025_%28symbol%29.svg.png";
    hash = "sha256-PO3Bl6IS3vq4aP+wsy9sA86a41lyss5yHl9b0FzwXyQ=";
  };
  meta = {
    description = "Desktop application for ChatGPT (packaged via Pake)";
    homepage = "https://chatgpt.com/";
    license = lib.licenses.unfree;
    mainProgram = "chatgpt";
  };
}
