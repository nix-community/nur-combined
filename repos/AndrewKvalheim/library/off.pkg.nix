{ lib
, resholve

  # Dependencies
, bash
, btrfs-progs
, nom-wrappers
, udo
}:

let
  inherit (builtins) readFile;
  inherit (lib) getExe getExe';
in
resholve.writeScriptBin "off"
{
  interpreter = getExe bash;
  inputs = [ btrfs-progs nom-wrappers udo ];
  execer = [
    "cannot:${getExe' nom-wrappers "nom-home-manager"}"
    "cannot:${getExe' nom-wrappers "nom-nixos-rebuild"}"
  ];
  fake.external = [
    # Runtime dependencies
    "docker"
    "nix-channel"
    "poweroff"
    "systemctl"

    # Pending abathur/resholve#29
    "runuser"
    "sudo"
  ];
  fake.function = [ "udo" ];
}
  (readFile ./assets/off.sh)
