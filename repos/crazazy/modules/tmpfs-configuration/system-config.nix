{ pkgs, config, lib, ... }:
let
  sources = import ../../nix/sources.nix;
  inherit (sources) impermanence;
in
with lib;
{
  imports = [
    "${impermanence.outPath}/nixos.nix"
  ];
  config = mkIf config.tmpfs-setup.enable {
    environment.persistence."/nix/persist" = {
      directories = [
        "/etc/NetworkManager"
      ];
      files = [
        "/etc/machine-id"
      ];
    };
  };
}
