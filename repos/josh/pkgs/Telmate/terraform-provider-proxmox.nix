{ terraform-providers }:
let
  pkg = terraform-providers.mkProvider {
    owner = "Telmate";
    repo = "terraform-provider-proxmox";
    rev = "v3.0.2-rc07";
    hash = "sha256-38q64EwxcdFzmlkL/jA0bTAF0WKXHEBIO0yS/44PizA=";
    vendorHash = "sha256-ZuH+uIv+iRQgUooyXsryICItSRglk1AGGWMVb+o1ILs=";
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
  }
)
