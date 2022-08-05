{pkgs, lib, colors ? null, ...}:
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
  company.enable = true;
  language-support = {
    nix.enable = true;
    markdown.enable = true;
    golang.enable = true;
  };
  performance.startup.increase-gc-threshold-on-init = true;
  yasnippet = {
    enable = true;
    global-mode.enable = true;
    official-snippets.enable = true;
  };
  org = {
    enable = true;
    roam = {
      enable = true;
      ack-v2 = true;
    };
  };
  helm.enable = true;
  # nogui = true;
  themes.base16-pallete = colors.colors or null;
  plugins = with pkgs.emacsPackages; [
    auctex
    org-roam-ui
    company-math
    emmet-mode
  ];
  initEl.pos = builtins.readFile ./custom.el;
}

