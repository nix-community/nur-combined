{ ... }:
{
  sane.programs.lemoa = {
    sandbox.method = "bwrap";
    sandbox.wrapperType = "wrappedDerivation";
    sandbox.net = "clearnet";
    sandbox.whitelistDbus = [ "user" ];  # for clicking links
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;
    # creds
    persist.byStore.private = [ ".local/share/io.github.lemmygtk.lemoa" ];
  };
}
