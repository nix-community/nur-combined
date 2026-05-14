{ config, lib, ... }:

let
  inherit (config) host;
  inherit (lib) mkOption;
  inherit (lib.types) bool float int path submodule;
in
{
  imports = [
    ./components/applications.system.nix
    ./components/apt-cache.system.nix
    ./components/backup.system.nix
    ./components/boot.system.nix
    ./components/desktop.system.nix
    ./components/firmware.system.nix
    ./components/keyboard.system.nix
    ./components/llm.system.nix
    ./components/locale.system.nix
    ./components/logs.system.nix
    ./components/mail.system.nix
    ./components/networking.system.nix
    ./components/nix.system.nix
    ./components/openpgp.system.nix
    ./components/policy.system.nix
    ./components/power.system.nix
    ./components/printer.system.nix
    ./components/scanner.system.nix
    ./components/ssh.system.nix
    ./components/storage.system.nix
    ./components/syncthing.system.nix
    ./components/tor.system.nix
    ./components/u2f.system.nix
    ./components/updates.system.nix
    ./components/users.system.nix
    ./components/virtualization.system.nix
    ./components/wireguard.system.nix
  ];

  options = {
    host = {
      dir = mkOption { type = path; };

      metrics = {
        cpuCores = mkOption { type = int; };
        cpuMarkMulti = mkOption { type = int; };
        cpuMarkSingle = mkOption { type = int; };
        displayDensity = mkOption { type = float; };
        displayWidth = mkOption { type = int; };
        ramGb = mkOption { type = int; };
        vramGb = mkOption { type = int; };
      };

      features = with host.metrics; {
        llm = mkOption { type = bool; default = vramGb >= 8; };
        vm = mkOption { type = bool; default = cpuMarkMulti >= 10000 && ramGb >= 8; };
      };
    };
  };
}
