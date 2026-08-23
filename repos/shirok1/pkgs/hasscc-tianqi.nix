{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
}:

buildHomeAssistantComponent {
  owner = "hasscc";
  domain = "tianqi";
  version = "0.0.1-unstable";

  src = fetchFromGitHub {
    owner = "hasscc";
    repo = "tianqi";
    rev = "bbc166f6b1caa25becb34b1764576616486290dd";
    hash = "sha256-RNJbvnsVpVj5AebehGo4jzUafnGx/mDAItghnbBH3zg=";
  };

  meta = {
    description = "天气预报HomeAssistant集成，支持15天及逐小时预报、各种生活指数，兼容彩云卡片，无需申请appkey";
    homepage = "https://github.com/hasscc/tianqi/";
    license = lib.licenses.asl20;
  };
}
