{ ... }:
{
  sane.programs.evince = {
    buildCost = 1;

    sandbox.autodetectCliPaths = "existingFile";
    sandbox.whitelistWayland = true;

    mime.associations."application/pdf" = "org.gnome.Evince.desktop";
  };
}
