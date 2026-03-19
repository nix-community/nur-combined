{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "age-edit";
  version = "0.16.0";

  src = fetchFromGitHub {
    owner = "dbohdan";
    repo = "age-edit";
    tag = "v${version}";
    hash = "sha256-YVbLV45z2bkrVqTBneuk8pQpY7bm68NQcPizihqSrG0=";
  };

  proxyVendor = true;

  vendorHash = "sha256-u3bYsVsSGF9DLS6bjdOycEfmzz20L0etDs6c1LriRkA=";

  meta = {
    description = "Edit files encrypted with age";
    homepage = "https://github.com/dbohdan/age-edit";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [renesat];
    mainProgram = "age-edit";
  };
}
