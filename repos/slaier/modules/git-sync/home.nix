{ config, ... }:
{
  services.git-sync = {
    enable = true;
    repositories = {
      navi-tldr-pages = {
        uri = "https://github.com/denisidoro/navi-tldr-pages.git";
        path = "${config.xdg.dataHome}/navi/cheats/navi-tldr-pages";
      };
      cheats = {
        uri = "https://github.com/slaier/cheats.git";
        path = "${config.xdg.dataHome}/navi/cheats/cheats";
      };
    };
  };
}
