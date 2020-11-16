{pkgs, ...}: 
let 
  globalConfig = import <dotfiles/globalConfig.nix>;
  nur = pkgs.nur;
in
{
  programs.firefox = {
    enable = true;
    package = 
      if globalConfig.selectedDesktopEnvironment == "gnome"
      then
        pkgs.firefox-wayland
      else
        pkgs.firefox-bin;
    extensions = with nur.repos.rycee.firefox-addons; [
      ublock-origin
      darkreader
      i-dont-care-about-cookies
      facebook-container
    ];
    profiles.main = {
      name = "Lucas";
      settings = {
        "browser.search.region" = "BR";
        "browser.search.isUS" = false;
        "reader.color_scheme" = "dark";
        "extensions.pocket.settings.premium_status" = 1;
        "trailhead.firstrun.didSeeAboutWelcome" = true;
        "app.normandy.first_run" = false;
      };
      isDefault = true;
      userChrome = ''
      '';
      userContent = ''
        /* Hide scrollbar in FF Quantum */
        *{scrollbar-width:none !important}
      '';
    };
    # enableAdobeFlash = true;
  };
}
