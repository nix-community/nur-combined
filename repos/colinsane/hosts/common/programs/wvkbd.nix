{ lib, pkgs, ... }:
{
  sane.programs.wvkbd = {
    packageUnwrapped = pkgs.wvkbd.overrideAttrs (base: {
      postPatch = (base.postPatch or "") + ''
        substituteInPlace layout.mobintl.h \
          --replace-fail '#define KBD_KEY_BORDER 2' '#define KBD_KEY_BORDER 1'
      '';
    });

    sandbox.whitelistWayland = true;
    sandbox.mesaCacheDir = ".cache/wvkbd/mesa";  # TODO: is this the correct app-id?

    env.KEYBOARD = "wvkbd-mobintl";

    services.wvkbd = {
      description = "wvkbd: wayland virtual keyboard";
      # depends = [ "graphical-session" ];
      partOf = [ "graphical-session" ];
      command = lib.escapeShellArgs [
        "env"
        # --hidden: send SIGUSR2 to unhide
        # wvkbd layers:
        # - full
        # - landscape
        # - special  (e.g. coding symbols like ~)
        # - emoji
        # - nav
        # - simple  (like landscape, but no parens/tab/etc; even fewer chars)
        # - simplegrid  (simple, but grid layout)
        # - dialer  (digits)
        # - cyrillic
        # - arabic
        # - persian
        # - greek
        # - georgian
        "WVKBD_LANDSCAPE_LAYERS=landscape,special,emoji"
        "WVKBD_LAYERS=full,special,emoji"
        "WVKBD_HEIGHT=216"  #< default: 250 (pixels)
        # "WVKBD_LANDSCAPE_HEIGHT=??"  #< default: 120 (pixels)
        # more settings tunable inside config.h when compiling:
        # - KBD_KEY_BORDER = 2
        "wvkbd-mobintl"
        "--hidden"
      ];
    };
  };
}
