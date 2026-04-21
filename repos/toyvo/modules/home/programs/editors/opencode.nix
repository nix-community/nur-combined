{
  config,
  lib,
  pkgs,
  stablePkgs,
  ...
}:

{
  config = lib.mkIf config.programs.opencode.enable {
    programs.opencode = {
      settings = {
        plugin = [ "superpowers@git+https://github.com/obra/superpowers.git" ];

        permission = {
          external_directory = {
            "${config.home.homeDirectory}/.config/opencode/**" = "allow";
            "${config.home.homeDirectory}/.local/share/opencode/**" = "allow";
            "${config.home.homeDirectory}/FQ/**" = "allow";
            "${config.home.homeDirectory}/Code/**" = "allow";
            "${config.home.homeDirectory}/Clone/**" = "allow";
            "${config.home.homeDirectory}/nixcfg/**" = "allow";
            "/nix/**" = "allow";
          };
        };

        mcp = {
          nixos = {
            type = "local";
            command = [ (lib.getExe stablePkgs.mcp-nixos) ];
            enabled = true;
          };
        };
      };
    };
  };
}
