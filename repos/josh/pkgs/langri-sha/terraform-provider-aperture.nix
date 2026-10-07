{
  terraform-providers,
  nix-update-script,
  runCommand,
}:
let
  pkg = terraform-providers.mkProvider {
    owner = "langri-sha";
    repo = "terraform-provider-aperture";
    rev = "v0.3.1";
    hash = "sha256-E3D+IPkvcQYpXFSbRP+z7a3C74KYX0lS2ysfwjTqfAE=";
    vendorHash = "sha256-AGzDsGom3f39FrXENbgPMiNJ3ghd9VO5MqT14T1qqj0=";
    provider-source-address = "registry.terraform.io/langri-sha/aperture";
    homepage = "https://github.com/langri-sha/terraform-provider-aperture";
    spdx = "Apache-2.0";
  };
in
pkg.overrideAttrs (
  finalAttrs: previousAttrs: {
    subPackages = [ "cmd/terraform-provider-aperture" ];
    passthru = previousAttrs.passthru // {
      tests = {
        version = runCommand "test-terraform-provider-aperture-version" { } ''
          grep --text --quiet "${finalAttrs.version}" \
            ${finalAttrs.finalPackage}/libexec/terraform-providers/*/*/*/*/*/terraform-provider-aperture_*
          touch $out
        '';
      };
      updateScript = nix-update-script {
        extraArgs = [
          "--version=stable"
          "--override-filename"
          "pkgs/langri-sha/terraform-provider-aperture.nix"
        ];
      };
    };

    meta = previousAttrs.meta // {
      description = "Terraform provider for Aperture by Tailscale";
    };
  }
)
