{ ... }:
{
  sane.programs.planify = {
    sandbox.method = "bwrap";
    sandbox.whitelistDbus = [ "user" ];  # for dconf? else it can't persist any tasks/notes
    sandbox.whitelistWayland = true;

    persist.byStore.private = [
      # TODO items as a sqlite database
      ".local/share/io.github.alainm23.planify"
    ];

    slowToBuild = true;  # webkitgtk-6.0; slow for desktop
  };
}
