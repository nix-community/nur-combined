{ pkgs
, vscode-pkg ? pkgs.vscodium
, extra-extensions ? [ ]
, extra-settings ? { }
}:

let
  defaultExtensions = (with pkgs.vscode-extensions; [
    arrterian.nix-env-selector
    gruntfuggly.todo-tree
    hashicorp.terraform
    jnoortheen.nix-ide
    ms-python.python
    timonwong.shellcheck
    viktorqvarfordt.vscode-pitch-black-theme
    vscodevim.vim
    yzhang.markdown-all-in-one
  ]);
  # Example on how to add a extension from the marketplace
  # ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
  #   name = "vscode-pitch-black-theme";
  #   publisher = "ViktorQvarfordt";
  #   version = "1.2.4";
  #   sha256 = "sha256-HTXToZv0WWFjuQiofEJuaZNSDTmCUcZ0B3KOn+CVALw=";
  # }];
  defaultSettings = {
    "editor.insertSpaces" = false;
    "git.enableCommitSigning" = true;
    "keyboard.dispatch" = "keyCode";
    "python.pythonPath" = "${pkgs.python3}/bin/python3";
    "redhat.telemetry.enabled" = false;
    "todo-tree.general.tags" = [ "BUG" "FIXME" "TODO" ];
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

in {
  programs.vscode = {
    enable = true;
    package = vscode-pkg;
    extensions = defaultExtensions ++ extra-extensions;
    userSettings = defaultSettings // extra-settings;
  };
}