{ ... }:
{
  sane.programs.lemoa = {
    buildCost = 1;
    sandbox.net = "clearnet";
    sandbox.whitelistDbus.user = true;  #< TODO: reduce  # for clicking links
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;
    # creds
    persist.byStore.private = [ ".local/share/io.github.lemmygtk.lemoa" ];
  };
}
