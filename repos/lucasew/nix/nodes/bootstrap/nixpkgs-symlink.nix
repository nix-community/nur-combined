{ pkgs, ... }:
{
  environment.etc.".nixpkgs-used".source = pkgs.path;
}
