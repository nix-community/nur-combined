{ pkgs ? import <nixpkgs> {} }:

rec {

  cntr = pkgs.callPackage ./pkgs/cntr {};

  conky-symbols = pkgs.callPackage ./pkgs/conky-symbols {};

  clearsans = pkgs.callPackage ./pkgs/clearsans {};

  eapol_test = pkgs.callPackage ./pkgs/eapol_test {};

  frida-tools = pkgs.callPackage ./pkgs/frida-tools { myPython3Packages = python3Packages; };

  gdbgui-donation = pkgs.callPackage ./pkgs/gdbgui {};

  inconsolata-nerdfonts = pkgs.callPackage ./pkgs/inconsolata-nerdfonts {};

  inxi = pkgs.callPackage ./pkgs/inxi {};

  nix-review-unstable = pkgs.callPackage ./pkgs/nix-review {};

  sourcetrail = pkgs.callPackage ./pkgs/sourcetrail {};

  perlPackages = {
    Pry = pkgs.callPackage ./pkgs/pry {};
  };

  python2Packages = pkgs.recurseIntoAttrs (pkgs.python2Packages.callPackage ./pkgs/python-pkgs.nix { });
  python3Packages = pkgs.recurseIntoAttrs (pkgs.python3Packages.callPackage ./pkgs/python-pkgs.nix { });

  modules = import ./modules;

  #inherit (callPackages ./node-packages {})
  #  typescript-language-server; # write-good
}
