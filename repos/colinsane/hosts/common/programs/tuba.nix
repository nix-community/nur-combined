{ ... }:
{
  sane.programs.tuba = {
    sandbox.method = "bwrap";
    sandbox.wrapperType = "wrappedDerivation";
    sandbox.net = "clearnet";
    suggestedPrograms = [ "gnome-keyring" ];
  };
}
