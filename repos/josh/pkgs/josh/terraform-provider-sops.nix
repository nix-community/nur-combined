{
  lib,
  terraform-providers,
  sops,
  nix-update-script,
}:
let
  pkg = terraform-providers.mkProvider {
    owner = "josh";
    repo = "terraform-provider-sops";
    rev = "v0.1.1";
    hash = "sha256-aLtLQtABpy6OCOCe1pQWN2VKaIqLx3b31PW7YrKouAs=";
    vendorHash = "sha256-RPs4Zh2rSmOYSD2ihNtKkoI5tcGL427GD3iIlQcD1AI=";
    provider-source-address = "registry.terraform.io/josh/sops";
    homepage = "https://github.com/josh/terraform-provider-sops";
    spdx = "MIT";
  };
in
pkg.overrideAttrs (
  _finalAttrs: previousAttrs: {
    ldflags = previousAttrs.ldflags ++ [ "-X main.sopsBinary=${lib.getExe sops}" ];
    passthru = previousAttrs.passthru // {
      updateScript = nix-update-script {
        extraArgs = [
          "--version=stable"
          "--override-filename"
          "pkgs/josh/terraform-provider-sops.nix"
        ];
      };
    };
  }
)
