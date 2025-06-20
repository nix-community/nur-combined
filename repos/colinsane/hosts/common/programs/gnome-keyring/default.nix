# TODO: gnome-keyring has portal integration? ($out/share/xdg-desktop-portal)
{ lib, pkgs, ... }:
{
  sane.programs.gnome-keyring = {
    packageUnwrapped = pkgs.rmDbusServices pkgs.gnome-keyring;
    sandbox.capabilities = [
      # ipc_lock: used to `mlock` the secrets so they don't get swapped out.
      # this is optional, and user namespacing (bwrap) likely doesn't propagate it anyway
      "ipc_lock"
    ];
    sandbox.extraRuntimePaths = [
      "keyring"  #< only needs keyring/control, but has to *create* that.
      # "keyring/control"
    ];
    sandbox.whitelistDbus.user.own = [ "org.freedesktop.secrets" "org.gnome.keyring" ];

    persist.byStore.private = [
      # N.B.: gnome-keyring-daemon used to remove symlinks and replace them with empty directories, but as of 2024-09-05 that seems no longer the case.
      ".local/share/keyrings"
    ];

    services.gnome-keyring = {
      description = "gnome-keyring-daemon: secret provider";
      partOf = [ "graphical-session" ];
      command = let
        default_keyring = pkgs.writeText "Default_keyring.keyring" ''
          [keyring]
          display-name=Default keyring
          lock-on-idle=false
          lock-after=false
        '';
        gkr-start = pkgs.writeShellScriptBin "gnome-keyring-daemon-start" ''
          set -eu
          # XXX(2024-09-05): this service races with the creation of the keyrings directory, so wait for it to appear
          test -e ~/.local/share/keyrings
          # N.B.: certain keyring names have special significance
          # `login.keyring` is forcibly encrypted to the user's password, so that pam gnome-keyring can unlock it on login.
          # - it does this re-encryption forcibly, any time it wants to write to the keyring.
          echo -n "Default_keyring" > ~/.local/share/keyrings/default
          cp ${default_keyring} --update=none ~/.local/share/keyrings/Default_keyring.keyring

          mkdir -m 0700 -p $XDG_RUNTIME_DIR/keyring
          exec gnome-keyring-daemon --start --foreground --components=secrets
        '';
      in lib.getExe gkr-start;
      readiness.waitDbus = "org.gnome.keyring";
    };
  };
}
