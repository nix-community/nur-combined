{ ... }:
{
  sane.programs.quadrapassel = {
    sandbox.whitelistWayland = true;
    persist.byStore.plaintext = [
      ".local/share/quadrapassel"  #< scores
    ];
  };
}
