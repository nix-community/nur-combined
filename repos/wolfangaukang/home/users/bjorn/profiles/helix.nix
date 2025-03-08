{ pkgs
, ...
}:

let
  theme = "ayu_dark";

in {
  programs.helix = {
    enable = true;
    defaultEditor = true;
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
  home = {
    file.".config/helix/themes/${theme}.toml".source = "${pkgs.helix}/lib/runtime/themes/${theme}.toml";
    packages = with pkgs; [
      # Bash
      nodePackages.bash-language-server
      # Markdown
      marksman
      # Nix
      nil
      # TOML
      taplo
      # YAML
      yaml-language-server
    ];
  };
}
