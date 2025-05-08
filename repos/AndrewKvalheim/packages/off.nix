{ lib
, resholve

  # Dependencies
, bash
}:

let
  inherit (builtins) readFile;
  inherit (lib) getExe;
in
resholve.writeScriptBin "off" {
  interpreter = getExe bash;
  inputs = [ ];
  fake.external = [
    "btrfs"
    "docker"
    "home-manager"
    "nix-channel"
    "podman"
    "sudo" # Pending https://github.com/abathur/resholve/issues/29
    "vagrant"
  ];
} (readFile ./resources/off)
