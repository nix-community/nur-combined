{
  system,
  pkgs,
}:
{
  trev-mono = pkgs.callPackage ./trev-mono { inherit system; };
}
