{ config, lib, pkgs, ... }:

with lib;
let
  iconDir = pkgs.runCommand "icons" { preferLocalBuild = true; } ''
    mkdir -p "$out"
    ${concatMapStrings (p: ''
        if [ -d "${p}/share/icons" ]; then
            cp -rn --no-preserve=mode,ownership "${p}/share/icons/." "$out"
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
