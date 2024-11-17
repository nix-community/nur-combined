{ ... }:
{
  sane.programs.celeste64 = {
    buildCost = 1;

    sandbox.whitelistAudio = true;
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;
    sandbox.extraPaths = [
      "/dev/input"  #< for controllers
    ];

    persist.byStore.plaintext = [
      # save data, controls map
      ".local/share/Celeste64"
    ];
  };
}
