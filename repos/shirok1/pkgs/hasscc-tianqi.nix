{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
}:

buildHomeAssistantComponent rec {
  owner = "hasscc";
  domain = "tianqi";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "hasscc";
    repo = "tianqi";
    rev = "e0424d1ca9f984dcbd30d491fb7d84e28331f14d";
    hash = "sha256-0HmcRkAnuLC76hjWOhiU9eR0d17O30ICFe1bzKMn6RI=";
  };

  meta = {
    description = "天气预报HomeAssistant集成，支持15天及逐小时预报、各种生活指数，兼容彩云卡片，无需申请appkey";
    homepage = "https://github.com/hasscc/tianqi/";
    license = lib.licenses.asl20;
  };
}
