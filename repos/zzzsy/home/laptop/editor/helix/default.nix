{
  imports = [ ./langs.nix ];

  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      theme = "everforest_dark";
      keys.normal = {
        "X" = "extend_line_above";
        space.space = "file_picker";
        space.w = ":w";
        space.q = ":bc";
        "C-q" = ":xa";
        space.u = {
          f = ":format";
          w = ":set whitespace.render all";
          W = ":set whitespace.render none";
        };
      };
      editor = {
        line-number = "relative";
        true-color = true;
        color-modes = true;
        cursorline = true;
        bufferline = "multiple";
        completion-replace = true;
        gutters = [
          "diff"
          "diagnostics"
          "line-numbers"
          "spacer"
        ];
        soft-wrap = {
          enable = true;
        };
        statusline = {
          left = [
            "mode"
            "spinner"
          ];
          center = [ "file-name" ];
          right = [
            "diagnostics"
            "selections"
            "position"
            "file-line-ending"
            "file-type"
            "version-control"
          ];
          separator = "|";
          mode = {
            normal = "NORMAL";
            insert = "INSERT";
            select = "SELECT";
          };
        };
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        indent-guides = {
          render = true;
          skip-levels = 1;
          character = "▏";
        };
        whitespace = {
          render = {
            space = "all";
          };
        };
        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };
      };
    };
  };
}
