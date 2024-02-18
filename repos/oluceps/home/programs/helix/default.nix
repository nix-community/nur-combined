{ pkgs
, lib
, ...
}:
{
  xdg.configFile =
    let
      settingsFormat = pkgs.formats.toml { };
      genText = x: y: builtins.readFile (settingsFormat.generate x y);
    in
    {
      "helix/languages.toml".text =
        genText "config.toml" (import ./languages.nix { inherit pkgs lib; });
      "helix/themes/catppuccin_macchiato.toml".text =
        genText "catppuccin_macchiato.toml" (import ./catppuccin_macchiato.nix);
    };

  # lsps
  home.packages = with pkgs;[
    rust-analyzer
    nil
    shfmt
    nixpkgs-fmt
    # taplo
    rustfmt
    clang-tools
    haskell-language-server
    cmake-language-server
    typst-lsp
    vhdl-ls
    delve
    python311Packages.python-lsp-server
  ]
  ++ (with pkgs.nodePackages_latest; [
    vscode-json-languageserver-bin
    vscode-html-languageserver-bin
    vscode-css-languageserver-bin
    bash-language-server
    vls
    prettier
  ]);

  programs.helix = {
    enable = true;
    package = pkgs.helix;

    settings = {
      theme = "catppuccin_macchiato";
      editor = {
        line-number = "relative";
        auto-pairs = true;
        true-color = true;
        cursorline = true;
        color-modes = true;
        soft-wrap = { enable = false; };

        lsp = {
          enable = true;
          display-messages = true;
          display-inlay-hints = false;
          snippets = true;
        };

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        indent-guides = {
          render = true;
          character = "┊";
        };

        file-picker.hidden = false;

        statusline = {
          left = [ "mode" "spinner" ];
          center = [ "file-name" ];
          right = [
            "diagnostics"
            "selections"
            "position"
            "file-encoding"
            "file-line-ending"
            "file-type"
          ];
          separator = "│";
        };

      };

      keys.normal = {
        space = {
          s = ":w";
          m = ":format";
          q = ":q!";
        };

        C-j = map (_: "move_line_down") (lib.range 0 4);
        C-k = map (_: "move_line_up") (lib.range 0 4);
        C-e = "scroll_down";
        C-y = "scroll_up";

      };
      keys.select = {
        C-j = map (_: "extend_line_down") (lib.range 0 4);
        C-k = map (_: "extend_line_up") (lib.range 0 4);
      };
    };
  };
}
