{ colloid-gtk-theme, fetchFromGitHub }:
colloid-gtk-theme.overrideAttrs (
  final: prev: {
    version = "2026-08-08-unstable-2026-08-17";
    src = fetchFromGitHub {
      owner = "vinceliuice";
      repo = "Colloid-gtk-theme";
      rev = "6f000fc68eef6c18002bf3a112808d0e348abf4e";
      hash = "sha256-dkYd1GVYL0VmiQAPx7XHQtDWym44O0kpqVYhgvvLDNg=";
    };
  }
)
