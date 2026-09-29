{
  terraform-providers,
  nix-update-script,
  runCommand,
}:
let
  pkg = terraform-providers.mkProvider {
    owner = "ubiquiti-community";
    repo = "terraform-provider-unifi";
    rev = "v0.57.0";
    hash = "sha256-CgixAzMfdV4lsc14ZdXUrE2AE0wkHcjIi7C2pQROOg0=";
    vendorHash = "sha256-CtqDFTVJqbPF5riVrEdtLZhOxtK1MU2SbTf8xClksQw=";
    provider-source-address = "registry.terraform.io/ubiquiti-community/unifi";
    homepage = "https://github.com/ubiquiti-community/terraform-provider-unifi";
    spdx = "MPL-2.0";
  };
in
pkg.overrideAttrs (
  finalAttrs: previousAttrs: {
    passthru = previousAttrs.passthru // {
      tests = {
        version = runCommand "test-terraform-provider-unifi-version" { } ''
          test -x ${finalAttrs.finalPackage}/libexec/terraform-providers/*/*/*/${finalAttrs.version}/*/terraform-provider-unifi_${finalAttrs.version}
          touch $out
        '';
      };
      updateScript = nix-update-script {
        extraArgs = [
          "--version=stable"
          "--override-filename"
          "pkgs/ubiquiti-community/terraform-provider-unifi.nix"
        ];
      };
    };

    meta = previousAttrs.meta // {
      description = "Terraform provider for UniFi network controllers";
    };
  }
)
