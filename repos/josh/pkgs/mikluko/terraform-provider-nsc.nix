{
  terraform-providers,
  nix-update-script,
  runCommand,
}:
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
  finalAttrs: previousAttrs: {
    passthru = previousAttrs.passthru // {
      tests = {
        version = runCommand "test-terraform-provider-nsc-version" { } ''
          grep --text --quiet "${finalAttrs.version}" \
            ${finalAttrs.finalPackage}/libexec/terraform-providers/*/*/*/*/*/terraform-provider-nsc_*
          touch $out
        '';
      };
      updateScript = nix-update-script {
        extraArgs = [
          "--version=stable"
          "--override-filename"
          "pkgs/mikluko/terraform-provider-nsc.nix"
        ];
      };
    };

    meta = previousAttrs.meta // {
      description = "Terraform provider for NATS Synadia Cloud";
    };
  }
)
