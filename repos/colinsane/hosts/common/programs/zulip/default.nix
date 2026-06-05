{ ... }:
{
  sane.programs.zulip = {
    sandbox.net = "clearnet";
    sandbox.whitelistDbus.user = true;  #< TODO: reduce  # notifications (i hope!)
    sandbox.whitelistWayland = true;
    # creds
    persist.byStore.private = [ ".config/Zulip" ];
  };
}
