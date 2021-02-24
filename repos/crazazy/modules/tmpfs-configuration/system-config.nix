{ pkgs, config, lib, ... }:
let
  inherit (pkgs.sources) impermanence;
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
