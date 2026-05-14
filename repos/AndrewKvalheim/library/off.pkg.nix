{ lib
, resholve

  # Dependencies
, bash
, nom-wrappers
}:

let
  inherit (builtins) readFile;
  inherit (lib) getExe getExe';
in
resholve.writeScriptBin "off" {
  interpreter = getExe bash;
  inputs = [ nom-wrappers ];
  execer = [
    "cannot:${getExe' nom-wrappers "nom-home-manager"}"
    "cannot:${getExe' nom-wrappers "nom-nixos-rebuild"}"
  ];
  fake.external = [
    "btrfs"
    "docker"
    "home-manager"
    "nix-channel"
    "podman"
    "sudo" # Pending https://github.com/abathur/resholve/issues/29
    "vagrant"
  ];
} (readFile ./assets/off.sh)
