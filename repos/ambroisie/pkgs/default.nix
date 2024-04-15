{ pkgs }:
pkgs.lib.makeScope pkgs.newScope (pkgs: {
  bw-pass = pkgs.callPackage ./bw-pass { };

  change-audio = pkgs.callPackage ./change-audio { };

  change-backlight = pkgs.callPackage ./change-backlight { };

  comma = pkgs.callPackage ./comma { };

  diff-flake = pkgs.callPackage ./diff-flake { };

  dragger = pkgs.callPackage ./dragger { };

  drone-rsync = pkgs.callPackage ./drone-rsync { };

  i3-get-window-criteria = pkgs.callPackage ./i3-get-window-criteria { };

  lohr = pkgs.callPackage ./lohr { };

  matrix-notifier = pkgs.callPackage ./matrix-notifier { };

  osc52 = pkgs.callPackage ./osc52 { };

  osc777 = pkgs.callPackage ./osc777 { };

  rbw-pass = pkgs.callPackage ./rbw-pass { };

  unbound-zones-adblock = pkgs.callPackage ./unbound-zones-adblock { };

  zsh-done = pkgs.callPackage ./zsh-done { };
})
