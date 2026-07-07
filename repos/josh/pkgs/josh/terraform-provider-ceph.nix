{ terraform-providers, nix-update-script }:
let
  pkg = terraform-providers.mkProvider {
    owner = "josh";
    repo = "terraform-provider-ceph";
    rev = "v0.7.0";
    hash = "sha256-rF60ZJ7TmTjB18f+eSXdTfrxQRpfPJ3RqjNCgK1bgQg=";
    vendorHash = "sha256-dHh08OzvZvPe9TY3JCsayDj43hNInv9IB4nWNOXOeV4=";
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
