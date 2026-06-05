{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.swaylock;
in
{
  sane.programs.swaylock = {
    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options.autolock = mkOption {
          type = types.bool;
          default = true;
          description = ''
            integrate with things like `swayidle` to auto-lock when appropriate.
          '';
        };
      };
    };

    # packageUnwrapped = pkgs.swaylock.overrideAttrs (upstream: {
    #   # XXX(2026-01-01): swaylock performs `shadow`-based auth iff built without pam.
    #   # shadow auth (`getspnam`) is a lot easier to use:
    #   # - glibc: reads `/etc/nsswitch.conf` & retrieves password hash from the `shadow` database.
    #   # - musl: reads password hash from `/etc/tcb/$user/shadow`.
    #   mesonFlags = (lib.remove "-Dpam=enabled" upstream.mesonFlags) ++ [
    #     "-Dpam=disabled"
    #   ];
    #   buildInputs = upstream.buildInputs ++ [
    #     pkgs.libxcrypt
    #   ];
    # });

    # packageUnwrapped = pkgs.swaylock.overrideAttrs (upstream: {
    #   nativeBuildInputs = (upstream.nativeBuildInputs or []) ++ [
    #     pkgs.copyDesktopItems
    #   ];
    #   desktopItems = (upstream.desktopItems or []) ++ [
    #     (pkgs.makeDesktopItem {
    #       name = "swaylock";
    #       exec = "swaylock --indicator-idle-visible --indicator-radius 100 --indicator-thickness 30";
    #       desktopName = "Lock Session";
    #     })
    #   ];
    # });

    sandbox.extraPaths = [
      # N.B.: we need to be able to follow /etc/shadow to wherever it's symlinked.
      # swaylock seems (?) to offload password checking to pam's `unix_chkpwd`,
      # which needs read access to /etc/shadow. that can be either via suid bit (default; incompatible with sandbox)
      # or by making /etc/shadow readable by the user (which is what i do -- check the activationScript)
      # "/etc/shadow"
      # XXX(2026-01-01): switched to tcb-based auth, where each user's shadow is R/W by that user, at a unique path:
      "/etc/tcb/colin/shadow"
    ];
    sandbox.whitelistWayland = true;

    services.swaylock = {
      description = "swaylock screen locker";
      command = "swaylock --indicator-idle-visible --indicator-radius 100 --indicator-thickness 30";
      restartCondition = "on-failure";
    };
  };

  sane.programs.swayidle.config = lib.mkIf (cfg.enabled && cfg.config.autolock) {
    actions.lock.service = "swaylock";
  };

  security.pam.services = lib.mkIf cfg.enabled {
    # XXX(2026-01-29): tcb pam is PROBABLY only needed for non-musl platforms, as pam_unix invokes getspnam (which does tcb lookups on musl).
    # but this is yet-untested.
    swaylock.rules.auth.tcb = lib.mkIf (!pkgs.stdenv.hostPlatform.isMusl) {
      order = 10900;  # pam_unix order is 11600: we'll be earlier
      modulePath = "${pkgs.tcb}/lib/security/pam_tcb.so";
      control = "sufficient";  # if pam_tcb passes auth, short-circuit & grant the user access
      settings.likeauth = true;  #< taken from pam_unix defaults
      settings.shadow = true;  #< use getspnam (not just getpwname) for passwd queries (i.e. actually do consult /etc/shadow, /etc/tcb/$user/shadow).
      settings.try_first_pass = true;  #< taken from pam_unix defaults
    };
  };
}
