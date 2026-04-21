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
