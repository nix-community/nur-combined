{ pkgs, ... }:
{
  sane.programs.s6-rc = {
    packageUnwrapped = pkgs.s6-rc.overrideAttrs (upstream: {
      nativeBuildInputs = (upstream.nativeBuildInputs or []) ++ (with pkgs; [
        makeWrapper
      ]);
      # s6-rc looks for files in /run/s6/{live,compiled,...} by default.
      # let's patch that to be a user-specific runtime dir, since i run it as an ordinary user.
      # note that one can still manually specify --live; later definitions will override earlier definitions.
      postInstall = (upstream.postInstall or "") + ''
        for prog in s6-rc s6-rc-bundle s6-rc-db s6-rc-format-upgrade s6-rc-init s6-rc-update; do
          wrapProgram "$bin/bin/$prog" \
            --add-flags '-l $XDG_RUNTIME_DIR/s6/live'
        done
      '';
    });

    persist.private = [
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
