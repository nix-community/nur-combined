{ config, lib, pkgs, ... }:
let
  cfg = config.sane.gui.unl0kr;
  tty = "tty${builtins.toString cfg.vt}";
  redirect-tty = pkgs.static-nix-shell.mkPython3Bin {
    pname = "redirect-tty";
    src = ./.;
  };
  launcher = pkgs.writeShellApplication {
    name = "unl0kr-login";
    runtimeInputs = [
      cfg.package
      pkgs.shadow
      redirect-tty
    ];
    text = ''
      # TODO: if unl0kr or the redirection fails unexpectedly, this will sit here indefinitely
      #       (well, user can use /dev/stdin to auth -- if that's wired to a usable input device)
      # could either:
      # - wait on `unl0kr` to complete _before_ starting `login`, and re-introduce a timeout to `login`
      #   i.e. `pw=$(unl0kr); (sleep 1 && echo "$pw" | redirect-tty "/dev/(tty)") &; login -p <user>`
      #   but modified to not leak pword to CLI
      # - implement some sort of watchdog (e.g. detect spawned children?)
      # - set a timeout at the outer scope (which gets canceled upon successful login)

      redirect-tty "/dev/${tty}" unl0kr &
      # login -p: preserve environment
      login -p ${cfg.user}
    '';
  };
in
{
  options = with lib; {
    sane.gui.unl0kr.enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        whether to launch unl0kr at boot.
        unl0kr takes the role of a greeter, presenting a virtual keyboard to the framebuffer
        and allowing password auth via either keyboard, mouse, or touch.
      '';
    };
    sane.gui.unl0kr.vt = mkOption {
      type = types.int;
      default = 1;
    };
    sane.gui.unl0kr.user = mkOption {
      type = types.str;
      default = "colin";
    };
    sane.gui.unl0kr.afterLogin = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        shell code to run after a successful login (via .profile).
      '';
    };
    sane.gui.unl0kr.delay = mkOption {
      type = types.int;
      default = 3;
      description = ''
        seconds to wait between successful login and running the `afterLogin` command.
        this is a safety mechanism, to allow users an exit in case DE is broken.
      '';
    };
    sane.gui.unl0kr.package = mkOption {
      type = types.package;
      default = pkgs.unl0kr;
    };
    sane.gui.unl0kr.launcher = mkOption {
      type = types.package;
      default = launcher;
      description = ''
        script to tie `unl0kr` and `login` together.
        exposed for debugging.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # prevent nixos-rebuild from killing us after a redeploy
    systemd.services."autovt@${tty}".enable = false;
    systemd.services.unl0kr = {
      # --skip-login is funny here: it *doesn't* skip the login; rather it has getty not try to read the username for itself
      #   and instead launch --login-program *immediately*
      # N.B.: exec paths here must be absolute. neither systemd nor agetty query PATH.
      serviceConfig.ExecStart = "${pkgs.util-linux}/bin/agetty --login-program '${cfg.launcher}/bin/unl0kr-login' --noclear --skip-login --keep-baud ${tty} 115200,38400,9600 $TERM";

      serviceConfig.Type = "simple";
      serviceConfig.Restart = "always";
      serviceConfig.RestartSec = "5";
      # XXX: unsure which of these are necessary nor what they do.
      # copied from greetd and agetty services.
      serviceConfig.TTYPath = "/dev/${tty}";
      serviceConfig.TTYReset = "yes";
      serviceConfig.StandardInput = "tty";
      serviceConfig.StandardOutput = "tty";

      # copied from greetd; not sure how `after` and `conflict` being identical makes any sense.
      after = [ "getty@${tty}.service" ];
      conflicts = [ "getty@${tty}.service" ];
      wantedBy = [ "graphical.target" ];

      # don't kill session on nixos re-deploy
      restartIfChanged = false;
    };

    systemd.defaultUnit = "graphical.target";

    # lib.mkAfter so that launching the DE happens *after* any other .profile setup.
    # alternatively, we could recurse: exec a new login shell with some env-var signalling to not launch the DE,
    #   run with `-c "{cfg.afterLogin}"`
    sane.users."${cfg.user}".fs.".profile".symlink.text = lib.mkAfter (lib.optionalString (cfg.afterLogin != null) ''
      # if already running a desktop environment, or if running from ssh, then `tty` will show /dev/pts/NN.
      if [ "$(tty)" = "/dev/${tty}" ]; then
        echo 'launching default session in ${builtins.toString cfg.delay}s'
        sleep ${builtins.toString cfg.delay} && exec ${cfg.afterLogin}
      fi
    '');

    # see: `man login.defs`
    # disable timeout for `login` program.
    # LOGIN_TIMEOUT=0 lets me pipe input into `login` and not worry about the pipe randomly dying.
    security.loginDefs.settings.LOGIN_TIMEOUT = 0;
    # LOGIN_RETRIES=1 ensures that if the password is wrong, then login exits and the whole service restarts so unl0kr re-appears.
    # docs mention `UNIX_MAX_RETRIES` setting within pam_unix (hardcoded to 3): seems that's an upper-limit to this value, but no lower limit.
    security.loginDefs.settings.LOGIN_RETRIES = 1;
    security.loginDefs.settings.FAIL_DELAY = 1;  #< delay this long after failed loging before allowing retry
  };
}
