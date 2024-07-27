{ lib, pkgs, ... }: {
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-wayland;
    profiles.default = {
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [ ublock-origin ];
      settings = {
        # Enable Multi-Account Containers
        "privacy.userContext.enabled" = true;
        "privacy.userContext.ui.enabled" = true;
      };
    };
  };

  xdg.mimeApps.defaultApplications =
    lib.attrsets.genAttrs [ "x-scheme-handler/http" "x-scheme-handler/https" ]
    (_: [ "firefox.desktop" ]);
}
