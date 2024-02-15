{ ... }:
{
  sane.programs.evince = {
    sandbox.method = "bwrap";
    sandbox.autodetectCliPaths = true;
    sandbox.whitelistWayland = true;

    mime.associations."application/pdf" = "org.gnome.Evince.desktop";
  };
}
