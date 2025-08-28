{pkgs, ...}:
pkgs.hyprshot.overrideAttrs {
  src = pkgs.fetchFromGitHub {
    owner = "Gustash";
    repo = "hyprshot";
    rev = "f95068db7765b85a2bbae0f083e29074d7bee027";
    hash = "sha256-9vsBNe6qTvbw2rgf1y5MIxN1eZzdCtimMvEXF8M36cQ=";
  };
}
