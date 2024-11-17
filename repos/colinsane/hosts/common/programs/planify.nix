{ ... }:
{
  sane.programs.planify = {
    sandbox.whitelistWayland = true;

    persist.byStore.private = [
      # TODO items as a sqlite database
      ".local/share/io.github.alainm23.planify"
    ];
    # TODO: can probably configure gsettings statically?
    # but until then it needs this to not lose its notes
    gsettingsPersist = [ "io/github/alainm23/planify" ];

    buildCost = 2;  # webkitgtk-6.0; slow for desktop
  };
}
