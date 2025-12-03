{ pkgs, ... }:
{
  sane.programs.s6-rc = {
    packageUnwrapped = pkgs.s6-rc.overrideAttrs (upstream: {
      nativeBuildInputs = (upstream.nativeBuildInputs or []) ++ (with pkgs; [
        makeWrapper  # requires shell wrapper -- not binary -- so that env var args can be expanded by the wrapper
      ]);
      # s6-rc looks for files in /run/s6/{live,compiled,...} by default.
      # let's patch that to be a user-specific runtime dir, since i run it as an ordinary user.
      # note that one can still manually specify --live; later definitions will override earlier definitions.
      postInstall = (upstream.postInstall or "") + ''
        for prog in s6-rc s6-rc-bundle s6-rc-db s6-rc-format-upgrade s6-rc-init s6-rc-update; do
          wrapProgram "$bin/bin/$prog" \
            --add-flag '-l' --add-flags '$XDG_RUNTIME_DIR/s6/live'
        done
      '';
    });

    # N.B.: we can't persist anything to `private` storage at this point,
    # because mounting the private storage generally relies on having a service manager running.
    persist.byStore.ephemeral = [
      ".local/share/s6/logs"
    ];

    sandbox.enable = false;  # service manager
    suggestedPrograms = [
      "s6-rc-man-pages"
      "s6"  #< TODO: i think i only need s6-svscan?
      "s6-man-pages"
    ];
  };

  sane.programs.s6.sandbox.enable = false;  # service manager
  sane.programs.s6-man-pages.sandbox.enable = false;  # no binaries
  sane.programs.s6-rc-man-pages.sandbox.enable = false;  # no binaries
}
