{
  getForgejoFlake,
  system,
  pkgs,
}:
{
  shellhook = pkgs.callPackage ./shellhook {
    inherit getForgejoFlake system;
  };
  trev-mono = pkgs.callPackage ./trev-mono {
    inherit getForgejoFlake system;
  };
}
