{ terraform-providers }:
let
  pkg = terraform-providers.mkProvider {
    owner = "Telmate";
    repo = "terraform-provider-proxmox";
    rev = "v3.0.2-rc10";
    hash = "sha256-uZxq/vrvhqvi897G/rxFK89dV+zsvcks9oZf1V28NwA=";
    vendorHash = "sha256-MySaED4kj+F2rYaYu1rpw5qUQFBx9u2Prpn+nqvqqA0=";
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
