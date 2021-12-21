{pkgs, lib, ...}:
pkgs.wrapEmacs {
  magit.enable = true;
  lsp = {
    enable = true;
    lsp-ui.enable = true;
  };
  evil = {
    enable = true;
    escesc = true;
    collection = true;
  };
  language-support = {
    nix.enable = true;
    markdown.enable = true;
  };
  plugins = with pkgs.emacsPackages; [
    org-roam
  ];
  org = {
    enable = true;
    roam = {
      enable = true;
      ack-v2 = true;
    };
  };
  # nogui = true;
  themes.selected = "wombat";
  initEl.pos = builtins.readFile ./custom.el;
}

