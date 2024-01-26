{ ... }:
{
  sane.programs.tuba = {
    sandbox.method = "bwrap";
    suggestedPrograms = [ "gnome-keyring" ];
  };
}
