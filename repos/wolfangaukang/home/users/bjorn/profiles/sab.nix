{ config, ... }:

{
  programs.sab = {
    enable = true;
    bots = {
      trovo = {
        settingsPath = "${config.home.homeDirectory}/Projektujo/Python/stream-alert-bot/etc/settings-trovo.yml";
        consumerType = "trovo";
      };
      twitch = {
        settingsPath = "${config.home.homeDirectory}/Projektujo/Python/stream-alert-bot/etc/settings-twitch.yml";
        consumerType = "twitch";
      };
    };
  };
}
