{ ... }:
{
  sane.programs.tuba = {
    sandbox.method = "bwrap";
    sandbox.wrapperType = "wrappedDerivation";
    suggestedPrograms = [ "gnome-keyring" ];
  };
}
