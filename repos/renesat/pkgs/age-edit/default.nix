{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "age-edit";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "dbohdan";
    repo = "age-edit";
    tag = "v${version}";
    hash = "sha256-/tXw0WZRJuBl6Mpyhjatt1khQ432KAP0YYJxu104ui4=";
  };

  proxyVendor = true;

  vendorHash = "sha256-ZxAUl5ZncNdBzxqiavrFY4T21uYWDViPFa2Sn9TiI1c=";

  meta = {
    description = "Edit files encrypted with age";
    homepage = "https://github.com/dbohdan/age-edit";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [renesat];
    mainProgram = "age-edit";
  };
}
