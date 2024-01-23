{ ... }:
{
  sane.programs.evince = {
    sandbox.method = "bwrap";
    sandbox.extraConfig = [
      "--sane-sandbox-autodetect"
    ];
    mime.associations."application/pdf" = "org.gnome.Evince.desktop";
  };
}
