{ pkgs }:
{
  AIMicroStructure      = pkgs.perlPackages.callPackage ./pkgs/perl-packages.nix	{};
  portfolio-performance = pkgs.callPackage ./portfolio-performance	{};
  realvnc               = pkgs.callPackage ./realvnc 			{};
}
