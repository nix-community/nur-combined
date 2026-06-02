{ terraform-providers, nix-update-script }:
let
  pkg = terraform-providers.mkProvider {
    owner = "josh";
    repo = "terraform-provider-ceph";
    rev = "v0.6.4";
    hash = "sha256-SR0ls1WvNeVsAYEhxLzyFH76p4pCOO3oEXnZba86LII=";
    vendorHash = "sha256-Y/TBEbWq8brLul74loIYn4sXF0RX1HxaVCi2cR13J+s=";
    provider-source-address = "registry.terraform.io/josh/ceph";
    homepage = "https://github.com/josh/terraform-provider-ceph";
    spdx = "MIT";
  };
in
pkg.overrideAttrs (
  _finalAttrs: previousAttrs: {
    passthru = previousAttrs.passthru // {
      updateScript = nix-update-script {
        extraArgs = [
          "--version=stable"
          "--override-filename"
          "pkgs/josh/terraform-provider-ceph.nix"
        ];
      };
    };
  }
)
