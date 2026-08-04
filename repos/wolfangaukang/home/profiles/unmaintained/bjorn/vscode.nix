{
  pkgs,
  ...
}:

{
  programs.vscode = {
    enable = true;
    pkgs = pkgs.vscodium;
    extensions = with pkgs.vscode-extensions; [
      mkhl.direnv
      gruntfuggly.todo-tree
      jnoortheen.nix-ide
      timonwong.shellcheck
      viktorqvarfordt.vscode-pitch-black-theme
      vscodevim.vim
      yzhang.markdown-all-in-one
      #hashicorp.terraform
      #ms-python.python
    ];
    settings = {
      "editor.insertSpaces" = false;
      "git.enableCommitSigning" = true;
      "keyboard.dispatch" = "keyCode";
      "python.pythonPath" = "${pkgs.python3}/bin/python3";
      "redhat.telemetry.enabled" = false;
      "todo-tree.general.tags" = [
        "BUG"
        "FIXME"
        "TODO"
      ];
      "vim.enableNeovim" = true;
      "vim.neovimPath" = "${pkgs.neovim}/bin/nvim";
      "window.zoomLevel" = -1;
      "window.restoreWindows" = "none";
      "workbench.colorTheme" = "Pitch Black";
      "[python]" = {
        "editor.insertSpaces" = true;
        "editor.tabSize" = 4;
      };
    };
  };
}
