{pkgs, config, lib, ...}:
let
  inherit (lib) mkIf mkEnableOption;
in {
  options.lsp.lsp-ui.enable = mkEnableOption "lsp-ui";
  config = mkIf (config.lsp.enable && config.lsp.lsp-ui.enable) {
    plugins = with pkgs.emacsPackages; [
      lsp-ui
    ];
  };
}
