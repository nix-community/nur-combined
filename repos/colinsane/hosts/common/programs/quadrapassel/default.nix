{ ... }:
{
  sane.programs.quadrapassel = {
    buildCost = 1;
    sandbox.whitelistWayland = true;
    persist.byStore.plaintext = [
      ".local/share/quadrapassel"  #< scores
    ];
  };
}
