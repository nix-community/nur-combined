{ pkgs, ... }:
{
  SF-Pro = (pkgs.callPackage ./common.nix {
    name = "SF-Pro";
    fontName = "SF Pro Fonts";
    sha256 = "sha256-B8xljBAqOoRFXvSOkOKDDWeYUebtMmQLJ8lF05iFnXk=";
  });
  SF-Compact = (pkgs.callPackage ./common.nix {
    name = "SF-Compact";
    fontName = "SF Compact Fonts";
    sha256 = "sha256-Mkf+GK4iuUhZdUdzMW0VUOmXcXcISejhMeZVm0uaRwY=";
  });
  SF-Mono = (pkgs.callPackage ./common.nix {
    name = "SF-Mono";
    fontName = "SF Mono Fonts";
    sha256 = "sha256-Uarx1TKO7g5yVBXAx6Yki065rz/wRuYiHPzzi6cTTl8=";
  });
  SF-Arabic = (pkgs.callPackage ./common.nix {
    name = "SF-Arabic";
    fontName = "SF Arabic Fonts";
    sha256 = "sha256-1clBp+aePSLNR9JrS+jReH7pEJtsH+zpzsiBKLQvvUs=";
  });
  NY = (pkgs.callPackage ./common.nix {
    name = "NY";
    fontName = "NY Fonts";
    sha256 = "sha256-yYyqkox2x9nQ842laXCqA3UwOpUGyIfUuprX975OsLA=";
  });
}
