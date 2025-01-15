{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "age-edit";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "dbohdan";
    repo = "age-edit";
    rev = "v${version}";
    hash = "sha256-4lafZiqUlxHPhuFkTMbVdbk/IhhqjpeaquJekOWqZ1g=";
  };

  proxyVendor = true;

  vendorHash = "sha256-BqQu4VDDcL5clnPyyb8NC0W7ty9vfoIppfr9tz4h1vE=";

  meta = {
    description = "Edit files encrypted with age";
    homepage = "https://github.com/dbohdan/age-edit";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [renesat];
    mainProgram = "age-edit";
  };
}
