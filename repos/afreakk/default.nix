{ pkgs, ... }:
let
  tmuxHlp = import ./tmuxhelpers.nix { inherit pkgs; };
  self = {
    irc-link-informant = pkgs.callPackage ./pkgs/irc-link-informant { };
    realm-cli = pkgs.callPackage ./pkgs/realm-cli { };
    fish-history-merger = pkgs.callPackage ./pkgs/fish-history-merger { };
    qutebrowser-start-page = pkgs.callPackage ./pkgs/qutebrowser-start-page { };
    wowup = pkgs.callPackage ./pkgs/wowup { };
    strongdm = pkgs.callPackage ./pkgs/sdm { };
    dmenu-afreak = pkgs.callPackage ./pkgs/dmenu { };
    dmenuhist = pkgs.callPackage ./pkgs/dmenuhist { };
    dcreemer-1pass = pkgs.callPackage ./pkgs/dcreemer-1pass { };
    mongosh = pkgs.callPackage ./pkgs/mongosh { };
    url-handler-tmux = tmuxHlp.mkDerivation rec {
      pluginName = "url-handler-tmux";
      version = "17380ba2ed513bc4f61ccd517b26aecdbac84fce";
      src = pkgs.fetchFromGitHub {
        owner = "afreakk";
        repo = pluginName;
        rev = version;
        sha256 = "sha256-L4nu1QX4IE9J1HDTo/qizGgrSVwwgweL6gJWLTJvTHE=";
      };
    };
    modules = {
      strongdm = import ./modules/sdm;
      systemd-cron = import ./modules/systemd-cron;
      scheduled-rsync = import ./modules/scheduled-rsync;
      joystickwake = import ./modules/joystickwake;
      xscreensaver-fork = import ./modules/xscreensaver;
    };
    system-modules = {
      irc-link-informant = import ./modules/irc-link-informant;
    };
  };
in
self
