{ terraform-providers }:
let
  pkg = terraform-providers.mkProvider {
    owner = "Telmate";
    repo = "terraform-provider-proxmox";
    rev = "v3.0.2-rc08";
    hash = "sha256-oRGBOyWwS/pv0ETmDBLmVUScqxHWc4EX+yWwyTCzCsI=";
    vendorHash = "sha256-r34lRNmmd2Q3iyCC5qU96H1NmUJ5kMFfhN+JGnu35Ik=";
    provider-source-address = "registry.terraform.io/Telmate/proxmox";
    homepage = "https://github.com/Telmate/terraform-provider-proxmox";
    spdx = "MIT";
  };
in
# Telmate ships only release candidates on the 3.0.x line, which nix-update's
# --version=stable refuses to track. Drop the default updateScript so the daily
# Update workflow skips this provider; bump it manually instead.
pkg.overrideAttrs (
  _finalAttrs: previousAttrs: {
    passthru = builtins.removeAttrs previousAttrs.passthru [ "updateScript" ];

    meta = previousAttrs.meta // {
      description = "Terraform provider for Proxmox VE";
    };
  }
)
