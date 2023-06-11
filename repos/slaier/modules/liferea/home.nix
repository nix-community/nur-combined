{ pkgs, ... }:
{
  home.packages = with pkgs; [
    liferea
  ];
  gtk.gtk3.extraCss = ''
    window > grid > paned scrolledwindow > treeview {
      font-family: Iosevka, Sarasa Mono SC, serif;
    }
  '';
  xdg.configFile."liferea/feedlist.opml" = {
    source = ./feedlist.opml;
    force = true;
  };
}
