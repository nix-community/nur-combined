{
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) getExe;
  inherit (pkgs)
    dprint
    marksman
    nil
    nixfmt-rfc-style
    rumdl
    taplo
    yaml-language-server
    ;
  inherit (pkgs.nodePackages) bash-language-server;
  theme = "ayu_dark";

in
{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    languages = {
      language-server = {
        bash-language-server.command = getExe bash-language-server;
        marksman.command = getExe marksman;
        nil.command = getExe nil;
        rumdl = {
          command = getExe rumdl;
          args = [ "server" ];
        };
        taplo.command = getExe taplo;
        yaml-language-server.command = getExe yaml-language-server;
      };
      language = [
        {
          name = "markdown";
          language-servers = [
            "marksman"
            "rumdl"
          ];
          soft-wrap = {
            enable = true;
            wrap-at-text-width = true;
          };
          text-width = 80;
          formatter = {
            command = getExe dprint;
            args = [
              "fmt"
              "--stdin"
              "md"
            ];
          };
          auto-format = true;
        }
        {
          name = "nix";
          formatter.command = getExe nixfmt-rfc-style;
          auto-format = true;
        }
      ];
    };
    settings = {
      inherit theme;
      editor = {
        bufferline = "multiple";
        cursorline = true;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        indent-guides = {
          character = "|";
          render = true;
        };
        line-number = "relative";
        lsp = {
          display-messages = true;
        };
        soft-wrap = {
          enable = true;
          wrap-indicator = "↪ ";
        };
      };
    };
  };
  home.file.".config/helix/themes/${theme}.toml".source =
    "${pkgs.helix}/lib/runtime/themes/${theme}.toml";
}
