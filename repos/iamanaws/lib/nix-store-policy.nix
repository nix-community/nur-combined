{ lib, hostConfig, ... }:
let
  workstation = lib.elem (hostConfig.device.profile or "core") [
    "desktop"
    "laptop"
  ];
  gib = 1024 * 1024 * 1024;
in
{
  # Start automatic GC below min-free and aim for max-free bytes available.
  # Core, server and VM profiles use smaller targets; hosts can override either.
  nix.settings = {
    min-free = lib.mkDefault ((if workstation then 20 else 2) * gib);
    max-free = lib.mkDefault ((if workstation then 40 else 5) * gib);
  };
}
