{ pkgs }:
{
  recurseForDerivations = true;
  charm = pkgs.callPackage ./charm { };
  confettysh = pkgs.callPackage ./confettysh { };
  crush = pkgs.callPackage ./crush { };
  freeze = pkgs.callPackage ./freeze { };
  glow = pkgs.callPackage ./glow { };
  gum = pkgs.callPackage ./gum { };
  markscribe = pkgs.callPackage ./markscribe { };
  melt = pkgs.callPackage ./melt { };
  mods = pkgs.callPackage ./mods { };
  pop = pkgs.callPackage ./pop { };
  sequin = pkgs.callPackage ./sequin { };
  skate = pkgs.callPackage ./skate { };
  soft-serve = pkgs.callPackage ./soft-serve { };
  vhs = pkgs.callPackage ./vhs { };
  wishlist = pkgs.callPackage ./wishlist { };
}
