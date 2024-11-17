{ ... }:
{
  sane.programs.mumble = {
    buildCost = 1;
    persist.byStore.private = [
      ".config/Mumble"  #< client cert, audio + UI settings
      ".local/share/Mumble"  #< sqlite db; probably server connections
    ];

    sandbox.net = "all";
    sandbox.whitelistWayland = true;
    sandbox.whitelistAudio = true;
  };
}
