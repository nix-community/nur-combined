{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.unl0kr;

  tty = "tty${builtins.toString cfg.config.vt}";
  redirect-tty = pkgs.static-nix-shell.mkPython3Bin {
    pname = "redirect-tty";
    srcRoot = ./.;
  };
  launcher = pkgs.writeShellApplication {
    name = "unl0kr-login";
    runtimeInputs = [
      # TODO: since this invokes `login`, adding these deps to PATH is questionable
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
      login -p ${cfg.config.user}
    '';
  };
in
{
  sane.programs.unl0kr = {
    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options.autostart = mkOption {
          type = types.bool;
          default = true;
          description = ''
            whether to launch unl0kr at boot.
            unl0kr takes the role of a greeter, presenting a virtual keyboard to the framebuffer
            and allowing password auth via either keyboard, mouse, or touch.
          '';
        };
        options.vt = mkOption {
          type = types.int;
          default = 1;
        };
        options.user = mkOption {
          type = types.str;
          description = ''
            which user to login by default.
            unl0kr is just a virtual keyboard for entering a password: one has to choose the user to login before launching it.
            on a typical single-user install, leave this unset and the user will be chosen based on who this package is installed for.
          '';
        };
        options.delay = mkOption {
          type = types.int;
          default = 3;
          description = ''
            seconds to wait between successful login and running the `afterLogin` command.
            this is a safety mechanism, to allow users an exit in case DE is broken.
          '';
        };
        options.launcher = mkOption {
          type = types.package;
          default = launcher;
          description = ''
            script to tie `unl0kr` and `login` together.
            exposed for debugging.
          '';
        };

        config = lib.mkMerge (lib.mapAttrsToList
          (userName: en: lib.optionalAttrs en {
            user = lib.mkDefault userName;
          })
          cfg.enableFor.user
        );
      };
    };

    fs.".profile".symlink.text = lib.mkMerge [
      (lib.mkBefore ''
        # setup primarySessionCommands here and let any other nix config populate it later
        primarySessionCommands=()
        initPrimarySession() {
          for c in "''${primarySessionCommands[@]}"; do
            eval "$c"
          done
        }
      '')
      # lib.mkAfter so that launching the DE happens *after* any other .profile setup.
      (lib.mkAfter ''
        # if already running a desktop environment, or if running from ssh, then `tty` will show /dev/pts/NN.
        if [ "$(tty)" = "/dev/${tty}" ]; then
          if (( ''${#primarySessionCommands[@]} )); then
            echo "launching primary session commands in ${builtins.toString cfg.config.delay}s: ''${primarySessionCommands[*]}"
            # if the `sleep` call here is `Ctrl+C'd`, then it'll exit false and the desktop isn't launched.
            sleep ${builtins.toString cfg.config.delay} && \
              initPrimarySession
          fi
        fi
      '')
    ];

    # N.B.: this sandboxing applies to `unl0kr` itself -- the on-screen-keyboard;
    #       NOT to the wrapper which invokes `login`.
    sandbox.method = "bwrap";
    sandbox.whitelistDri = true;
    sandbox.extraPaths = [
      "/dev/fb0"
      "/dev/input"
      "/run/udev"
      "/sys/class/input"
      "/sys/devices"
      #v without /dev/tty0, it fails to fully take over the tty (even though it's ostensibly running on ${cfg.config.vt})
      # and your password is dumped to the framebuffer.
      # it still *works*, but wow, kinda weird and concerning
      "/dev/tty0"
    ];
  };

  # unl0kr is run as root, and especially with sandboxing, needs to be installed for root if expected to work.
  sane.programs.unl0kr.enableFor.system = lib.mkIf (builtins.any (en: en) (builtins.attrValues cfg.enableFor.user)) true;

  systemd = lib.mkIf cfg.enabled {
    # prevent nixos-rebuild from killing us after a redeploy
    services."autovt@${tty}".enable = false;
    services.unl0kr = {
      # --skip-login is funny here: it *doesn't* skip the login; rather it has getty not try to read the username for itself
      #   and instead launch --login-program *immediately*
      # N.B.: exec paths here must be absolute. neither systemd nor agetty query PATH.
      serviceConfig.ExecStart = "${pkgs.util-linux}/bin/agetty --login-program '${cfg.config.launcher}/bin/unl0kr-login' --noclear --skip-login --keep-baud ${tty} 115200,38400,9600 $TERM";

      path = [
        # necessary for `sane-sandboxed` to be found. TODO: add this to every systemd service.
        "/run/current-system/sw"  # `/bin` is appended
      ];
      # needed to find sane-sandbox profiles (TODO: add this to every service)
      environment.XDG_DATA_DIRS = "/run/current-system/sw/share";

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

    defaultUnit = "graphical.target";
  };

  security.loginDefs.settings = lib.mkIf cfg.enabled {
    # see: `man login.defs`
    # disable timeout for `login` program.
    # LOGIN_TIMEOUT=0 lets me pipe input into `login` and not worry about the pipe randomly dying.
    LOGIN_TIMEOUT = 0;
    # LOGIN_RETRIES=1 ensures that if the password is wrong, then login exits and the whole service restarts so unl0kr re-appears.
    # docs mention `UNIX_MAX_RETRIES` setting within pam_unix (hardcoded to 3): seems that's an upper-limit to this value, but no lower limit.
    LOGIN_RETRIES = 1;
    FAIL_DELAY = 1;  #< delay this long after failed loging before allowing retry
  };
}
