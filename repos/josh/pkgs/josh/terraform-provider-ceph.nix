{
  terraform-providers,
  nix-update-script,
  runCommand,
}:
let
  pkg = terraform-providers.mkProvider {
    owner = "josh";
    repo = "terraform-provider-ceph";
    rev = "v0.9.1";
    hash = "sha256-fdr2sgnL/Ut4Ylt31S1y6IS8oWeyTefGNO+HhILZCxw=";
    vendorHash = "sha256-KMc0tnqDNOhgO6fL4f0vCqBmjMeyy7M/inq16HwDGFo=";
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
