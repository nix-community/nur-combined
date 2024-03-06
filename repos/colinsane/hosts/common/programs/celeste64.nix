{ ... }:
{
  sane.programs.celeste64 = {
    sandbox.method = "bwrap";
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
