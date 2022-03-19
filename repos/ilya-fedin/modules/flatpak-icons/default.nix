{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.xdg.icons;

  iconDir = pkgs.runCommand "icons" { preferLocalBuild = true; } ''
    mkdir -p "$out/share/icons"
    ${concatMapStrings (p: ''
        if [ -d "${p}/share/icons" ]; then
            find -L "${p}/share/icons" -mindepth 1 -maxdepth 1 -type d -exec cp -rn --no-preserve=mode,ownership {}/ "$out/share/icons" \;
        fi
    '') cfg.icons}
  '';
in {
  options = {
    xdg = {
      icons = {
        icons = mkOption {
          type = types.listOf types.package;
          default = [];
          example = literalExpression "[ pkgs.papirus-icon-theme pkgs.breeze-icons ]";
          description = ''
            The set of packages that appear in
            /usr/share/icons. These packages are
            automatically available to all users, and are
            automatically updated every time you rebuild the system
            configuration.
          '';
        };
      };
    };
  };

  config = mkIf (cfg.enable && cfg.icons != []) {
      environment.systemPackages = [ iconDir ];
      fileSystems."/usr/share/icons" = {
        device = "${iconDir}/share/icons";
        fsType = "none";
        options = [ "bind" ];
      };
  };
}
