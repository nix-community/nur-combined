{ colloid-gtk-theme, fetchFromGitHub }:
colloid-gtk-theme.overrideAttrs (
  final: prev: {
    version = "2026-08-08-unstable-2026-08-22";
    src = fetchFromGitHub {
      owner = "vinceliuice";
      repo = "Colloid-gtk-theme";
      rev = "fe11342f37f124f1b29d44cf33e9a06053f4bba2";
      hash = "sha256-Q6KPtWHN06KWBOwgxufRTGahh/Ij4ofvE1uODm0lytU=";
    };
  }
)
