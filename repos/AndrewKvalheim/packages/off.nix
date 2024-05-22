{ resholve

  # Dependencies
, bash
}:

let
  inherit (builtins) readFile;
in
resholve.writeScriptBin "off" {
  interpreter = "${bash}/bin/bash";
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
