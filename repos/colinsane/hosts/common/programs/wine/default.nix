{ pkgs, ... }:
{
  sane.programs.wine = {
    sandbox.method = null;
    # `pkgs.wine == pkgs.winePackages.full`
    # not sure the practical difference between `full` and `base`, but `full` drags in thngs like samba which i _probably_ don't need.
    # could build with `supportFlags.netapiSupport = false` to use `full` but without samba.
    packageUnwrapped = pkgs.winePackages.base;
    # no need for the cryptographic nature, just needs to not use loads of / tmpfs.
    persist.byStore.ephemeral = [ ".wine" ];
    persist.byStore.plaintext = [
      # Power Bomberman: <https://www.bombermanboard.com/viewtopic.php?t=1925>
      ".wine/drive_c/users/colin/AppData/pb"
    ];
  };
}
