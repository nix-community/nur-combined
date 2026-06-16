{ terraform-providers, nix-update-script }:
let
  pkg = terraform-providers.mkProvider {
    owner = "ubiquiti-community";
    repo = "terraform-provider-unifi";
    rev = "v0.52.2";
    hash = "sha256-U39JE+dLZJbbgN0jR+XCZpwlW5AZb2PoDHSLHQTj4C0=";
    vendorHash = "sha256-/LTibVu6+Gn46ep9rzdjTeZUywtL5ZFcgbjTtKgM2HM=";
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
