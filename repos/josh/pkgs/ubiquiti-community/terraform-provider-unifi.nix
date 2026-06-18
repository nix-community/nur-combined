{ terraform-providers, nix-update-script }:
let
  pkg = terraform-providers.mkProvider {
    owner = "ubiquiti-community";
    repo = "terraform-provider-unifi";
    rev = "v0.52.4";
    hash = "sha256-6VEnhqu+q16dNUO4OR0P6x0hS9wIHahr9wI/EPW0vBg=";
    vendorHash = "sha256-wGcF0Bwm3zMbxa9gD44QOJV74pTmv6jprDmxBDA6vos=";
    provider-source-address = "registry.terraform.io/ubiquiti-community/unifi";
    homepage = "https://github.com/ubiquiti-community/terraform-provider-unifi";
    spdx = "MPL-2.0";
  };
in
pkg.overrideAttrs (
  _finalAttrs: previousAttrs: {
    passthru = previousAttrs.passthru // {
      updateScript = nix-update-script {
        extraArgs = [
          "--version=stable"
          "--override-filename"
          "pkgs/ubiquiti-community/terraform-provider-unifi.nix"
        ];
      };
    };
  }
)
