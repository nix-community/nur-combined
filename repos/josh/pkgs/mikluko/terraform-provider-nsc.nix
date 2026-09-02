{
  terraform-providers,
  nix-update-script,
  runCommand,
}:
let
  pkg = terraform-providers.mkProvider {
    owner = "mikluko";
    repo = "terraform-provider-nsc";
    rev = "v0.14.0";
    hash = "sha256-qDmnWtW/fzFwO8JP3ViDhBG5yVq51WHVgjTPUZAiepQ=";
    vendorHash = "sha256-iaR/DysFwbsOGWGsOrc+yzT9QsaDpa+mBNU+GvgVNjA=";
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
