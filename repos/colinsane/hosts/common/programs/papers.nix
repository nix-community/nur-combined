{ ... }:
{
  sane.programs.papers = {
    buildCost = 2;  #< webkitgtk
    sandbox.method = "bunpen";
    sandbox.whitelistDbus = [ "user" ];  #< for clicking links
    sandbox.whitelistDri = true;  #< speedier
    sandbox.whitelistWayland = true;
    sandbox.autodetectCliPaths = "existingFile";

    mime.associations."application/pdf" = "org.gnome.Papers.desktop";
  };
}
