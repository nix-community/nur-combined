{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.eownerdead.firefox.enable = lib.mkEnableOption "Enable Firefox";

  config = lib.mkIf config.eownerdead.firefox.enable {
    programs.firefox = {
      enable = true;
      package = pkgs.firefox;
      profiles.default = {
        # path = lib.mkIf config.eownerdead.imperm.enable "${config.eownerdead.imperm.path}/;
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          web-archives
          tabwrangler
        ];
        settings = {
          # Enable Multi-Account Containers
          "privacy.userContext.enabled" = true;
          "privacy.userContext.ui.enabled" = true;
        };
      };
    };

    home.persistence."/nix/persist".directories =
      lib.mkIf config.eownerdead.imperm.enable
        [
          ".config/mozilla/firefox"
        ];

    xdg.mimeApps.defaultApplications = lib.attrsets.genAttrs [
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ] (_: [ "firefox.desktop" ]);
  };
}
