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
    rev = "v0.2.2";
    hash = "sha256-LX5zAm9znVp7aSyE9+0xOy9I7HvGdCxm+D3DgGOP3UQ=";
    vendorHash = "sha256-I0MuIc/9fOWvPx7tL+oueTBwLGLvxufo3j/Lt7Mobrw=";
    provider-source-address = "registry.terraform.io/josh/sops";
    homepage = "https://github.com/josh/terraform-provider-sops";
    spdx = "MIT";
  };
in
pkg.overrideAttrs (
  finalAttrs: previousAttrs: {
    ldflags = previousAttrs.ldflags ++ [ "-X main.sopsBinary=${lib.meta.getExe sops}" ];
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
          grep --text --quiet "${lib.meta.getExe sops}" \
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
