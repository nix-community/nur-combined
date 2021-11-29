{pkgs, lib, ...}:
pkgs.wrapEmacs {
  imports = [
    ./magit.nix
  ];
  magit.enable = true;
  evil = {
    enable = true;
    escesc = true;
    collection = true;
  };
  language-support = {
    nix.enable = true;
    markdown.enable = true;
  };
  org.enable = true;
  # nogui = true;
  themes.selected = "wombat";
  initEl.pre = ''
  (menu-bar-mode 0)
  (tool-bar-mode 0)
  '';
}
