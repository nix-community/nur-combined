{ system ? builtins.currentSystem, pkgs ? import <nixpkgs> { inherit system; } }:

rec {
  vaultwarden_ldap = pkgs.callPackage ./pkgs/vaultwarden_ldap { };

  cntr = pkgs.callPackage ./pkgs/cntr { };

  conky-symbols = pkgs.callPackage ./pkgs/conky-symbols { };

  eapol_test = pkgs.callPackage ./pkgs/eapol_test { };

  bing-image-creator = pkgs.callPackage ./pkgs/bing-image-creator { };
  edge-gpt = pkgs.callPackage ./pkgs/edge-gpt {
    inherit bing-image-creator;
  };

  fira-code-pro-nerdfonts = pkgs.nerdfonts.override {
    fonts = [ "FiraCode" ];
  };

  gdb-dashboard = pkgs.callPackage ./pkgs/gdb-dashboard { };

  goatcounter = pkgs.callPackage ./pkgs/goatcounter { };

  hello-nur = pkgs.callPackage ./pkgs/hello-nur { };

  irc-announce = pkgs.callPackage ./pkgs/irc-announce { };

  ircsink = pkgs.callPackage ./pkgs/ircsink { };

  lualdap = pkgs.callPackage ./pkgs/lualdap { };

  mastodon-hnbot = pkgs.python3Packages.callPackage ./pkgs/mastodon-hnbot {};

  pandoc-bin = pkgs.callPackage ./pkgs/pandoc { };

  patool = pkgs.python3.pkgs.callPackage ./pkgs/patool {
    inherit (pkgs) libarchive;
  };

  peep = pkgs.callPackage ./pkgs/peep { };

  perlPackages = {
    Pry = pkgs.callPackage ./pkgs/pry { };
  };

  python3Packages = pkgs.recurseIntoAttrs (
    pkgs.python3Packages.callPackage ./pkgs/python-pkgs {}
  );

  rspamd-learn-spam-ham = pkgs.python3.pkgs.callPackage ./pkgs/rspam-learn-spam-ham { };

  inherit (pkgs.callPackages ./pkgs/node-packages { }) speedscope reveal-md;

  source-code-pro-nerdfonts = pkgs.nerdfonts.override {
    fonts = [ "SourceCodePro" ];
  };

  #peerix = pkgs.python3.pkgs.callPackage ./pkgs/peerix { };

  traceshark = pkgs.qt5.callPackage ./pkgs/traceshark { };

  untilport = pkgs.callPackage ./pkgs/untilport { };

  yubikey-touch-detector = pkgs.callPackage ./pkgs/yubikey-touch-detector { };

  noise-suppression-for-voice = pkgs.callPackage ./pkgs/noise-suppression-for-voice { };

  mailexporter = pkgs.callPackage ./pkgs/mailexporter { };

  modules = import ./modules;
}
