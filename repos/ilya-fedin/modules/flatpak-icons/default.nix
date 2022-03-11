{ config, lib, pkgs, ... }:

with lib;
let
  iconDir = pkgs.runCommand "icons" { preferLocalBuild = true; } ''
    mkdir -p "$out"
    ${concatMapStrings (p: ''
        if [ -d "${p}/share/icons" ]; then
            find -L "${p}/share/icons" -mindepth 1 -maxdepth 1 -type d -exec cp -rn --no-preserve=mode,ownership {}/ "$out" \;
        fi
    '') config.environment.systemPackages}
  '';
in {
  config = {
      fileSystems."/usr/share/icons" = {
        device = "${iconDir}";
        fsType = "none";
        options = [ "bind" ];
      };
  };
}
