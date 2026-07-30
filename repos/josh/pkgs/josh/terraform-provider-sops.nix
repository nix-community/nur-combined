{
  lib,
  terraform-providers,
  sops,
  nix-update-script,
  runCommand,
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
  finalAttrs: previousAttrs: {
    ldflags = previousAttrs.ldflags ++ [ "-X main.sopsBinary=${lib.getExe sops}" ];
    passthru = previousAttrs.passthru // {
      updateScript = nix-update-script {
        extraArgs = [
          "--version=stable"
          "--override-filename"
          "pkgs/josh/terraform-provider-sops.nix"
        ];
      };

      tests = {
        version = runCommand "test-terraform-provider-sops-version" { } ''
          grep --text --quiet "${finalAttrs.version}" \
            ${finalAttrs.finalPackage}/libexec/terraform-providers/*/*/*/*/*/terraform-provider-sops_*
          touch $out
        '';
        sops-path = runCommand "test-terraform-provider-sops-sops-path" { } ''
          grep --text --quiet "${lib.getExe sops}" \
            ${finalAttrs.finalPackage}/libexec/terraform-providers/*/*/*/*/*/terraform-provider-sops_*
          touch $out
        '';
      };
    };

    meta = previousAttrs.meta // {
      description = "Terraform provider for managing sops-encrypted files";
    };
  }
)
