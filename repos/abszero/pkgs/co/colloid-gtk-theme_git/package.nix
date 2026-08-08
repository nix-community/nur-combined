{ colloid-gtk-theme, fetchFromGitHub }:
colloid-gtk-theme.overrideAttrs (
  final: prev: {
    version = "2026-08-08-unstable-2026-08-07";
    src = fetchFromGitHub {
      owner = "vinceliuice";
      repo = "Colloid-gtk-theme";
      rev = "6c2dc65865628bda9fdc8157a30cd5eda6fd41f9";
      hash = "sha256-2FNX5S4xN86ljj1GxHRuloP31b/QLkTCmle90NkpcpA=";
    };
  }
)
