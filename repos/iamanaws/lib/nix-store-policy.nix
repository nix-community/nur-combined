{ lib, hostConfig, ... }:
let
  profile = lib.head (lib.splitString "/" (hostConfig.device.profile or "core"));
  workstation = lib.elem profile [
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
