{ pkgs, ... }:

{
  sane.programs.sublime-music = {
    package = pkgs.sublime-music-mobile;
    # sublime music persists any downloaded albums here.
    # it doesn't obey a conventional ~/Music/{Artist}/{Album}/{Track} notation, so no symlinking
    # config (e.g. server connection details) is persisted in ~/.config/sublime-music/config.json
    #   possible to pass config as a CLI arg (sublime-music -c config.json)
    persist.plaintext = [ ".local/share/sublime-music" ];

    secrets.".config/sublime-music/config.json" = ../../../secrets/universal/sublime_music_config.json.bin;
  };
}
