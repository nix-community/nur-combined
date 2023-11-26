{ ... }:
{
  sane.programs.wine = {
    # no need for the cryptographic nature, just needs to not use loads of / tmpfs.
    persist.byStore.cryptClearOnBoot = [ ".wine" ];
  };
}
