{
  lib,
  fetchFromGitHub,
  open-webui
}:

open-webui.overrideAttrs (oldAttrs: rec {
  pname = "open-webui-ztx888";
  version = "0.7.3-6";

  src = fetchFromGitHub {
    owner = "ztx888";
    repo = "open-webui";
    rev = "v${version}";
    hash = "sha256-6TlgyMH3A9LwMl02UJDaAdQYd0MT71yxPOWULZin6Yw=";
  };

  meta = with lib; oldAttrs.meta // {
    description = "Fork of Open WebUI with additional features and enhancements by ztx888";
    maintainers = with maintainers; [ codgician ];
  };
})
