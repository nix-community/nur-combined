{ ... }:
{
  sane.programs.delta = {
    sandbox.autodetectCliPaths = "existing";
    # N.B.: PAGER-related settings are set via page/default.nix.
  };
}
