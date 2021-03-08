{
  instantnix,
  pkgs
}:
{
    instantdata = pkgs.callPackage ../pkgs/tests/instantdata { inherit (instantnix) instantdata; };
}
