{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.helix;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      bash-language-server
      typescript-language-server
      clang-tools
      vscode-langservers-extracted
      nil
      marksman
      taplo
      yaml-language-server
      lldb
    ];
    catppuccin.helix = {
      enable = true;
      flavor = config.catppuccin.flavor;
    };
    programs.helix = {
      settings = {
        editor = {
          line-number = "relative";
          bufferline = "always";
        };
      };
    };
  };
}
