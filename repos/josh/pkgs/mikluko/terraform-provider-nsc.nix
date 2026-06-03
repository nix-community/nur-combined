{ terraform-providers, nix-update-script }:
let
  pkg = terraform-providers.mkProvider {
    owner = "mikluko";
    repo = "terraform-provider-nsc";
    rev = "v0.13.2";
    hash = "sha256-mKhp9FtqbWYd0bUlwRtQz2dNr+C2wmBoXprwPkNjOuc=";
    vendorHash = "sha256-Wig5xyCQ/K1B+oH3yhZ+uZdmTzTTiyefbDhtKO4uA/c=";
    provider-source-address = "registry.terraform.io/mikluko/nsc";
    homepage = "https://github.com/mikluko/terraform-provider-nsc";
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
          "pkgs/mikluko/terraform-provider-nsc.nix"
        ];
      };
    };
  }
)
