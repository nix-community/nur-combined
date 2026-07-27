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
    pter = pkgs.callPackage ./pkgs/pter { };
    url-handler-tmux = tmuxHlp.mkDerivation rec {
      pluginName = "url-handler-tmux";
      version = "ec950050f36e0060dcfa13059f56eb256f1ccb8a";
      src = pkgs.fetchFromGitHub {
        owner = "afreakk";
        repo = pluginName;
        rev = version;
        sha256 = "sha256-Oye6b8f3t1Yo+bGFaWh5AW75xMk52NEtO0QgBUQoXX4=";
      };
    };
    tmux-which-key =
      pkgs.tmuxPlugins.mkTmuxPlugin
        {
          pluginName = "tmux-which-key";
          version = "2024-11-12";
          src = pkgs.fetchFromGitHub {
            owner = "alexwforsythe";
            repo = "tmux-which-key";
            rev = "1f419775caf136a60aac8e3a269b51ad10b51eb6";
            sha256 = "sha256-X7FunHrAexDgAlZfN+JOUJvXFZeyVj9yu6WRnxMEA8E=";
          };
          rtpFilePath = "plugin.sh.tmux";
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
