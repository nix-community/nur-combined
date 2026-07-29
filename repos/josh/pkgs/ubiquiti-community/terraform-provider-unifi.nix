{
  terraform-providers,
  nix-update-script,
  runCommand,
}:
let
  pkg = terraform-providers.mkProvider {
    owner = "ubiquiti-community";
    repo = "terraform-provider-unifi";
    rev = "v0.55.0";
    hash = "sha256-pN/4HAQlcwr49WftYWqWRJWMuMuXFgrgC70WCn6tP3w=";
    vendorHash = "sha256-/5VP9ljeMyvikllhfZ4kUQgMEeyRKG3lfJjbp5SWtJ0=";
    provider-source-address = "registry.terraform.io/ubiquiti-community/unifi";
    homepage = "https://github.com/ubiquiti-community/terraform-provider-unifi";
    spdx = "MPL-2.0";
  };
in
pkg.overrideAttrs (
  finalAttrs: previousAttrs: {
    meta = previousAttrs.meta // {
      description = "Terraform provider for UniFi network controllers";
    };

    passthru = previousAttrs.passthru // {

      tests = {
        version = runCommand "test-terraform-provider-unifi-version" { } ''
          grep --text --quiet "${finalAttrs.version}" \
            ${finalAttrs.finalPackage}/libexec/terraform-providers/*/*/*/*/*/terraform-provider-unifi_*
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
  }
)
