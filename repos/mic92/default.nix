{ system ? builtins.currentSystem, pkgs ? import <nixpkgs> { inherit system; } }:

{
  vaultwarden_ldap = pkgs.callPackage ./pkgs/vaultwarden_ldap { };

  goatcounter = pkgs.callPackage ./pkgs/goatcounter { };

  hello-nur = pkgs.callPackage ./pkgs/hello-nur { };

  irc-announce = pkgs.callPackage ./pkgs/irc-announce { };

  ircsink = pkgs.callPackage ./pkgs/ircsink { };

  mastodon-hnbot = pkgs.python3Packages.callPackage ./pkgs/mastodon-hnbot {};

  rspamd-learn-spam-ham = pkgs.python3.pkgs.callPackage ./pkgs/rspam-learn-spam-ham { };

  untilport = pkgs.callPackage ./pkgs/untilport { };

  modules = import ./modules;
}
