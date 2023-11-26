{ ... }:
{
  sane.programs.wine = {
    # no need for the cryptographic nature, just needs to not use loads of / tmpfs.
    persist.byStore.cryptClearOnBoot = [ ".wine" ];
    persist.byStore.plaintext = [
      # Power Bomberman: <https://www.bombermanboard.com/viewtopic.php?t=1925>
      ".wine/drive_c/users/colin/AppData/pb"
    ];
  };
}
