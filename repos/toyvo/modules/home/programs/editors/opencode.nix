{
  config,
  lib,
  pkgs,
  stablePkgs,
  ...
}:

{
  config = lib.mkIf config.programs.opencode.enable {
    programs.opencode.settings = {
      plugin = [ "superpowers@git+https://github.com/obra/superpowers.git" ];

      permission = {
        external_directory = {
          "${config.home.homeDirectory}/.config/opencode/**" = "allow";
          "${config.home.homeDirectory}/.local/share/opencode/**" = "allow";
          "${config.home.homeDirectory}/.cargo/**" = "allow";
          "${config.home.homeDirectory}/Code/**" = "allow";
          "${config.home.homeDirectory}/Clone/**" = "allow";
          "${config.home.homeDirectory}/nixcfg/**" = "allow";
          "/nix/**" = "allow";
          "/tmp/**" = "allow";
        };
      };

      mcp = {
        nixos = {
          command = [ (lib.getExe stablePkgs.mcp-nixos) ];
          enabled = true;
          type = "local";
        };
        chrome-devtools = {
          command = [
            "npx"
            "-y"
            "chrome-devtools-mcp@latest"
          ];
          enabled = true;
          type = "local";
        };
      };
    };
  };
}
