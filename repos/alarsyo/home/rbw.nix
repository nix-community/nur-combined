{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;
  cfg = config.my.home.mail;
in {
  options.my.home.rbw = {
    enable = mkEnableOption "rbw configuration";
  };

  config = mkIf cfg.enable {
    programs.rbw = {
      enable = true;
      settings = {
        email = "antoine@alarsyo.net";
        base_url = "https://pass.alarsyo.net";
        lock_timeout = 60 * 60 * 12;
        pinentry = pkgs.pinentry-qt;
      };
    };

    # `rbw-agent` should be launched on first call to `rbw`, so this shouldn't
    # be necessary.
    #
    # However, if for instance `rbw` if first called by the emacs-daemon (when
    # accessing an IMAP account password), then restarting the user service
    # associated to the emacs daemon also kills the rbw-agent it spawned,
    # resetting the lock status and prompting for a passphrase again.
    #
    # This user service makes sure the rbw-agent is started when the user
    # session launches.
    systemd.user.services.rbw = {
      Unit.Description = "rbw agent autostart";

      Install.WantedBy = ["default.target"];

      Service = {
        ExecStart = "${pkgs.rbw}/bin/rbw-agent";
        Restart = "on-abort";
        Type = "forking";
        PIDFile = "%t/rbw/pidfile";
      };
    };
  };
}
