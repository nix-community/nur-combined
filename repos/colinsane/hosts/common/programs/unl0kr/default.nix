{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.unl0kr;
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
      };
    };

    # pkgs.unl0kr works fine, but the newer version packaged as part of buffybox is way more performant
    packageUnwrapped = pkgs.buffybox;

    # N.B.: this sandboxing applies to `unl0kr` itself -- the on-screen-keyboard;
    #       NOT to the wrapper which invokes `login`.
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

    services.unl0kr = {
      description = "unl0kr framebuffer password entry/filesystem unlocker";
      partOf = lib.mkIf cfg.config.autostart [ "private-storage" ];
      command = pkgs.writeShellScript "unl0kr-start" ''
        while ! test -f /mnt/persist/private/init; do
          if test -f /run/gocryptfs/private.key; then
            # wait for the mount to appear or for the key to disappear (because it was incorrect).
            # i'm not sure this is actually correct, or just behaves as `sleep 4` in practice
            ${lib.getExe' pkgs.inotify-tools "inotifywait"} --timeout 4 --event create --event delete /mnt/persist/private /run/gocryptfs
          else
            echo "starting unl0kr"
            if [ -n "$XDG_VTNR" ]; then
              # switch back to the tty our session is running on (in case the user tabbed away after logging in),
              # as only that TTY is sure to have echo disabled.
              # this is racy, but when we race it's obvious from the UI that your password is being echo'd
              ${lib.getExe' pkgs.kbd "chvt"} "$XDG_VTNR"
            fi
            # don't start unl0kr if there's no framebuffer yet, else it'll just not render anything, indefinitely.
            test -e /dev/fb0 && \
              unl0kr > /run/gocryptfs/private.key.incoming &&
              cp /run/gocryptfs/private.key.incoming /run/gocryptfs/private.key
            echo "unl0kr exited"
          fi
          sleep 1
        done
        while true; do
          sleep infinity
        done
      '';
    };
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

  environment.etc."unl0kr.conf" = lib.mkIf cfg.enabled {
    source = ./unl0kr.conf;
  };
}
