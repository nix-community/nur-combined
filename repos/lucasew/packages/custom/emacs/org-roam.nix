{pkgs, lib, config, ...}:
let
  inherit (lib) mkEnableOption mkIf;
in {
  options.org.roam = {
    enable = mkEnableOption "org-roam";
    ack-v2 = mkEnableOption "disable the annoying reminder about note migration from v1";
  };
  config = mkIf (config.org.enable && config.org.roam.enable) {
    plugins = with pkgs.emacsPackages; [
      org-roam
    ];
    initEl.pre = mkIf config.org.roam.ack-v2 ''
      (setq org-roam-v2-ack t)
    '';
  };
}
