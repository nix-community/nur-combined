{ pkgs ? import <nixpkgs> {} }:

rec {
  cntr = pkgs.callPackage ./pkgs/cntr {};

  inxi = pkgs.callPackage ./pkgs/inxi {};

  conky-symbols = pkgs.callPackage ./pkgs/conky-symbols {};

  clearsans = pkgs.callPackage ./pkgs/clearsans {};

  inconsolata-nerdfonts = pkgs.callPackage ./pkgs/inconsolata-nerdfonts {};

  gdbgui-donation = pkgs.callPackage ./pkgs/gdbgui {};

  frida-python = pkgs.callPackage ./pkgs/frida-python {};

  eapol_test = pkgs.callPackage ./pkgs/eapol_test {};

  sourcetrail = pkgs.callPackage ./pkgs/sourcetrail {};

  nix-review-unstable = pkgs.callPackage ./pkgs/nix-review {};

  perlPackages = {
    Pry = pkgs.callPackage ./pkgs/pry {};
  };

  python2Packages = pkgs.recurseIntoAttrs (pkgs.python2Packages.callPackage ./pkgs/python-pkgs.nix { });
  python3Packages = pkgs.recurseIntoAttrs (pkgs.python3Packages.callPackage ./pkgs/python-pkgs.nix { });

  modules = import ./modules;

  #inherit (callPackages ./node-packages {})
  #  typescript-language-server; # write-good
}
