{ ... }:
{
  sane.programs.tuba = {
    sandbox.method = "bwrap";
    sandbox.wrapperType = "wrappedDerivation";
    sandbox.net = "clearnet";
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus = [ "user" ];  # notifications
    sandbox.whitelistWayland = true;
    suggestedPrograms = [ "gnome-keyring" ];
  };
}
