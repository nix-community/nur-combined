{ pkgs, ... }:
{
  SF-Pro = (pkgs.callPackage ./common.nix {
    name = "SF-Pro";
    fontName = "SF Pro Fonts";
    sha256 = "sha256-m0eDv1CYCkkm5qgbLioI9+ahf0OXSYh0Gkp61vgMSFk=";
  });
  SF-Compact = (pkgs.callPackage ./common.nix {
    name = "SF-Compact";
    fontName = "SF Compact Fonts";
    sha256 = "sha256-uQAY1yMr9SetN/X6UrY2mvfxmIOmNQ0A3IrJQNvi5jM=";
  });
  SF-Mono = (pkgs.callPackage ./common.nix {
    name = "SF-Mono";
    fontName = "SF Mono Fonts";
    sha256 = "sha256-8niJPk3hGfK1USIs9eoxZ6GlM4aZ7ZObmQj2Zomj+Go=";
  });
  SF-Arabic = (pkgs.callPackage ./common.nix {
    name = "SF-Arabic";
    fontName = "SF Arabic Fonts";
    sha256 = "sha256-vlg0ZBEan5BQfJpSXHDqPTpvVKP/Y1MCnDDM2L3ioyo=";
  });
  NY = (pkgs.callPackage ./common.nix {
    name = "NY";
    fontName = "NY Fonts";
    sha256 = "sha256-MAxQkdR40YUDl7z0OYbuwiueOoB2JuYikIu11CqiAto=";
  });
}
