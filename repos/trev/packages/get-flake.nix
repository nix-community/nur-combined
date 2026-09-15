{
  getForgejoFlake,
  system,
  pkgs,
}:
{
  trev-mono = pkgs.callPackage ./trev-mono {
    inherit getForgejoFlake system;
  };
}
