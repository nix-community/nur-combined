{ ... }:
{
  sane.programs.planify = {
    persist.byStore.private = [
      # TODO items as a sqlite database
      ".local/share/io.github.alainm23.planify"
    ];

    slowToBuild = true;  # webkitgtk-6.0; slow for desktop
  };
}
