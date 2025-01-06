# TODO: gnome-keyring has portal integration? ($out/share/xdg-desktop-portal)
{ lib, pkgs, ... }:
{
  sane.programs.gnome-keyring = {
    packageUnwrapped = pkgs.rmDbusServices pkgs.gnome-keyring;
    sandbox.whitelistDbus.user = true;  #< TODO: reduce
    sandbox.extraRuntimePaths = [
      "keyring"  #< only needs keyring/control, but has to *create* that.
      # "keyring/control"
    ];
    sandbox.capabilities = [
      # ipc_lock: used to `mlock` the secrets so they don't get swapped out.
      # this is optional, and user namespacing (bwrap) likely doesn't propagate it anyway
      "ipc_lock"
    ];

    persist.byStore.private = [
      # N.B.: gnome-keyring-daemon used to remove symlinks and replace them with empty directories, but as of 2024-09-05 that seems no longer the case.
      ".local/share/keyrings"
    ];

    fs.".local/share/keyrings/default" = {
      file.text = "Default_keyring.keyring";  #< no trailing newline
      # wantedBy = [ config.sane.fs."${config.sane.persist.stores.private.origin}".unit ];
      # wantedBeforeBy = [  #< don't create this as part of `multi-user.target`
      #   "gnome-keyring.service"  # TODO: sane.programs should declare this dependency for us
      # ];
    };
    # N.B.: certain keyring names have special significance
    # `login.keyring` is forcibly encrypted to the user's password, so that pam gnome-keyring can unlock it on login.
    # - it does this re-encryption forcibly, any time it wants to write to the keyring.
    fs.".local/share/keyrings/Default_keyring.keyring" = {
      file.text = ''
        [keyring]
        display-name=Default keyring
        lock-on-idle=false
        lock-after=false
      '';
      # wantedBy = [ config.sane.fs."${config.sane.persist.stores.private.origin}".unit ];
      # wantedBeforeBy = [  #< don't create this as part of `multi-user.target`
      #   "gnome-keyring.service"
      # ];
    };

    services.gnome-keyring = {
      description = "gnome-keyring-daemon: secret provider";
      partOf = [ "graphical-session" ];
      command = let
        gkr-start = pkgs.writeShellScriptBin "gnome-keyring-daemon-start" ''
          set -eu
          # XXX(2024-09-05): this service races with the creation of the keyrings directory, so wait for it to appear
          test -e ~/.local/share/keyrings
          mkdir -m 0700 -p $XDG_RUNTIME_DIR/keyring
          exec gnome-keyring-daemon --start --foreground --components=secrets
        '';
      in lib.getExe gkr-start;
      readiness.waitDbus = "org.gnome.keyring";
    };
  };
}
