{ pkgs, ... }: {
  programs.kodi = {
    enable = true;
    package = pkgs.kodi-wayland.withPackages (p: with p; [ invidious ]);
  };
}
