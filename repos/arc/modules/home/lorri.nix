{ pkgs, config, lib, ... }: with lib; let
  cfg = config.services.lorri;
in {
  options.services.lorri = {
    enable = mkEnableOption "lorri";

    useNix = mkOption {
      type = types.bool;
      default = true;
    };

    package = mkOption {
      type = types.package;
      default = pkgs.lorri;
      defaultText = "pkgs.lorri";
    };
  };

  config = mkIf cfg.enable {
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

    systemd.user.sockets."lorri" = {
      Install.WantedBy = [ "sockets.target" ];
      Socket = {
        ListenStream = "%t/lorri/daemon.socket";
        RuntimeDirectory = "lorri";
      };
    };
    systemd.user.services."lorri" = {
      Unit = {
        Description = "lorri";
        ConditionUser = "!@system";
        After = [ "lorri.socket" ];
        Requires = [ "lorri.socket" ];
      };
      Service = {
        Type = "exec";
        Restart = "on-failure";
        PrivateTmp = true;
        ProtectSystem = "full"; # strict?
        ExecStart = "${cfg.package}/bin/lorri daemon";
      };
    };
  };
}
