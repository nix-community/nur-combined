{ pkgs, ... }:
{
  SF-Pro = (pkgs.callPackage ./common.nix {
    name = "SF-Pro";
    fontName = "SF Pro Fonts";
    sha256 = "sha256-nkuHge3/Vy8lwYx9z+pvsQZfzrNIP4K0OutpPl4yXn0=";
  });
  SF-Compact = (pkgs.callPackage ./common.nix {
    name = "SF-Compact";
    fontName = "SF Compact Fonts";
    sha256 = "sha256-+Q4HInJBl3FLb29/x9utf7A55uh5r79eh/7hdQDdbSI=";
  });
  SF-Mono = (pkgs.callPackage ./common.nix {
    name = "SF-Mono";
    fontName = "SF Mono Fonts";
    sha256 = "sha256-pqkYgJZttKKHqTYobBUjud0fW79dS5tdzYJ23we9TW4=";
  });
  SF-Arabic = (pkgs.callPackage ./common.nix {
    name = "SF-Arabic";
    fontName = "SF Arabic Fonts";
    sha256 = "sha256-MKcrCBtrxjm1DUZuvf2NKzcAzaiBjw1KgoDbKphrYkc=";
  });
  NY = (pkgs.callPackage ./common.nix {
    name = "NY";
    fontName = "NY Fonts";
    sha256 = "sha256-XOiWc4c7Yah+mM7axk8g1gY12vXamQF78Keqd3/0/cE=";
  });
}
