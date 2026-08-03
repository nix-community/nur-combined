{ colloid-gtk-theme, fetchFromGitHub }:
colloid-gtk-theme.overrideAttrs (
  final: prev: {
    version = "2025-07-31-unstable-2026-08-03";
    src = fetchFromGitHub {
      owner = "vinceliuice";
      repo = "Colloid-gtk-theme";
      rev = "f69f8195ef775685940bdd59e11952546a506c09";
      hash = "sha256-yD3MX1JDaW26SdJstlj2Di6wKrkRljkHQnio72K9cZE=";
    };
  }
)
