{
  terraform-providers,
  nix-update-script,
  runCommand,
}:
let
  pkg = terraform-providers.mkProvider {
    owner = "josh";
    repo = "terraform-provider-ceph";
    rev = "v0.8.1";
    hash = "sha256-TfHmQx63kBeGos1PVjvBDLJBCSOwG1IH2VsINfkHJRc=";
    vendorHash = "sha256-/2EJ4cBeOPx+4trvwO6Hee9P2rsy2cxVHTX0argUXEc=";
    provider-source-address = "registry.terraform.io/josh/ceph";
    homepage = "https://github.com/josh/terraform-provider-ceph";
    spdx = "MIT";
  };
in
pkg.overrideAttrs (
  finalAttrs: previousAttrs: {
    passthru = previousAttrs.passthru // {
      tests = {
        version = runCommand "test-terraform-provider-ceph-version" { } ''
          grep --text --quiet "${finalAttrs.version}" \
            ${finalAttrs.finalPackage}/libexec/terraform-providers/*/*/*/*/*/terraform-provider-ceph_*
          touch $out
        '';
      };
      updateScript = nix-update-script {
        extraArgs = [
          "--version=stable"
          "--override-filename"
          "pkgs/josh/terraform-provider-ceph.nix"
        ];
      };
    };

    meta = previousAttrs.meta // {
      description = "Terraform provider for managing Ceph resources";
    };
  }
)
