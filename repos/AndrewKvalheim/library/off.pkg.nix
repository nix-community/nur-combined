{ lib
, resholve

  # Dependencies
, bash
, btrfs-progs
, docker
, nix
, nom-wrappers
, systemd
}:

let
  inherit (builtins) readFile;
  inherit (lib) getExe getExe';
in
resholve.writeScriptBin "off"
{
  interpreter = getExe bash;
  inputs = [ btrfs-progs docker nix nom-wrappers systemd ];
  execer = [
    "cannot:${getExe docker}"
    "cannot:${getExe' nix "nix-channel"}"
    "cannot:${getExe' nom-wrappers "nom-home-manager"}"
    "cannot:${getExe' nom-wrappers "nom-nixos-rebuild"}"
    "cannot:${getExe' systemd "poweroff"}"
    "cannot:${getExe' systemd "systemctl"}"
  ];
  fake.external = [ "runuser" "sudo" ]; # Pending abathur/resholve#29
}
  (readFile ./assets/off.sh)
