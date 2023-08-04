{ pkgs }:
pkgs.lib.makeScope pkgs.newScope (pkgs: {
  bw-pass = pkgs.callPackage ./bw-pass { };

  change-audio = pkgs.callPackage ./change-audio { };

  change-backlight = pkgs.callPackage ./change-backlight { };

  comma = pkgs.callPackage ./comma { };

  diff-flake = pkgs.callPackage ./diff-flake { };

  dragger = pkgs.callPackage ./dragger { };

  drone-rsync = pkgs.callPackage ./drone-rsync { };

  drone-scp = pkgs.callPackage ./drone-scp { };

  ff2mpv-go = pkgs.callPackage ./ff2mpv-go { };

  i3-get-window-criteria = pkgs.callPackage ./i3-get-window-criteria { };

  lohr = pkgs.callPackage ./lohr { };

  matrix-notifier = pkgs.callPackage ./matrix-notifier { };

  osc52 = pkgs.callPackage ./osc52 { };

  rbw-pass = pkgs.callPackage ./rbw-pass { };

  unbound-zones-adblock = pkgs.callPackage ./unbound-zones-adblock { };

  unified-hosts-lists = pkgs.callPackage ./unified-hosts-lists { };

  vimix-cursors = pkgs.callPackage ./vimix-cursors { };

  volantes-cursors = pkgs.callPackage ./volantes-cursors { };

  wifi-qr = pkgs.callPackage ./wifi-qr { };
})
