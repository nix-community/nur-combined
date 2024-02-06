{ pkgs, ... }: {
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-wayland;
    profiles.default = {
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [ ublock-origin ];
    };
  };
}
