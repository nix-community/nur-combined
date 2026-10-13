{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
}:

buildHomeAssistantComponent (finalAttrs: {
  owner = "bemfa";
  domain = "bemfa_cloud";
  version = "0.1.15";

  src = fetchFromGitHub {
    owner = "bemfa";
    repo = "bemfa_cloud_ha";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kjUfxOpQIUyFTH8+Lc9wNCDJiFTz+TSMtjWiFaFflnk=";
  };

  meta = {
    description = "Home Assistant integration for syncing entities to Bemfa Cloud";
    homepage = "https://github.com/bemfa/bemfa_cloud_ha";
    license = lib.licenses.mit;
  };
})
