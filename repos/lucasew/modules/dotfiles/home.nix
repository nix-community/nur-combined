{ pkgs, ...}:
let
  globalConfig = import ../../globalConfig.nix;
in
{
  home.file.".dotfilerc".text = ''
    #!/usr/bin/env bash
    alias nixos-rebuild="sudo -E nixos-rebuild --flake '${globalConfig.rootPath}#acer-nix'"
  '';
}
