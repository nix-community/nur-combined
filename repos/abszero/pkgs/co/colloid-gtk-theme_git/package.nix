{ colloid-gtk-theme, fetchFromGitHub }:
colloid-gtk-theme.overrideAttrs (
  final: prev: {
    version = "2025-07-31-unstable-2025-12-05";
    src = fetchFromGitHub {
      owner = "vinceliuice";
      repo = "Colloid-gtk-theme";
      rev = "fd805dbeeacb12f7971b98408c415c3f472e5aef";
      hash = "sha256-BnULzudLLxzz7hYnUSwW6cbc7F3hX1dR3VHnxrA0zcM=";
    };
  }
)
