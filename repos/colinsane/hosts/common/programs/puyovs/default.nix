# source code: <https://github.com/puyonexus/puyovs>
{ ... }:
{
  sane.programs.puyovs = {
    # sandbox.net = "clearnet";  # net play (untested)
    sandbox.whitelistAudio = true;
    sandbox.whitelistWayland = true;

    persist.byStore.private = [
      ".local/share/PuyoVS"  # /Settings.json; includes user/pw
    ];
  };
}
