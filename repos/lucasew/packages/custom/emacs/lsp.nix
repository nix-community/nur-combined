{pkgs, lib, config, ...}:
let
  inherit (lib) mkIf mkEnableOption;
in {
  imports = [
    ./lsp-ui.nix
  ];
  options.lsp.enable = mkEnableOption "lsp-mode";
  config = mkIf config.lsp.enable {
    plugins = with pkgs.emacsPackages; [
      lsp-mode
    ];
  };
}
