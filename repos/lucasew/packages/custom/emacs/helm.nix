{pkgs, config, lib, ...}:
let
  inherit (lib) mkEnableOption;
in
{
  options.helm.enable = mkEnableOption "helm";
  config = {
    plugins = with pkgs.emacsPackages; [ helm ];
    initEl.pre = ''
      (setq helm-allow-mouse t)
      (global-set-key (kbd "M-x") #'helm-M-x)
      (global-set-key (kbd "C-x r b") #'helm-filtered-bookmarks)
      (global-set-key (kbd "C-x C-f") #'helm-find-files)

    '';
    initEl.main = ''
      (require 'helm)
    '';
    initEl.pos = ''
      (helm-mode 1)
    '';
  };
}
