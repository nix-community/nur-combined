{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
}:

buildHomeAssistantComponent (finalAttrs: {
  owner = "bemfa";
  domain = "behome";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "bemfa";
    repo = "behome";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aafVuU5kU9A6w2TCPM0oskGbrtFLYL5l9e5/3O3FeBw=";
  };

  meta = {
    description = "Home Assistant integration for BeHome/Bemfa smart home devices";
    homepage = "https://github.com/bemfa/behome";
    license = lib.licenses.mit;
  };
})
