{ pkgs, config, lib, ... }: with lib; let
  cfg = config.services.lorri;
in {
  options.services.lorri = {
    useNix = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable or false {
    programs.direnv = {
      enable = mkDefault true;
      stdlib = ''
        use_lorri() {
          eval "$(${pkgs.lorri}/bin/lorri direnv)"
        }
      '' + optionalString cfg.useNix ''
        use_nix() {
          use_lorri "$@"
        }
      '';
    };
  };
}
