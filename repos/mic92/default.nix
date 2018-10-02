{ pkgs ? import <nixpkgs> {} }:

rec {
  gdb-dashboard = pkgs.callPackage ./pkgs/gdb-dashboard {};

  # TODO checksum can break ... make a mirror?
  # binary-ninja = pkgs.callPackage ./pkgs/binary-ninja {};

  cntr = pkgs.callPackage ./pkgs/cntr {};

  conky-symbols = pkgs.callPackage ./pkgs/conky-symbols {};

  clearsans = pkgs.callPackage ./pkgs/clearsans {};

  eapol_test = pkgs.callPackage ./pkgs/eapol_test {};

  frida-tools = pkgs.callPackage ./pkgs/frida-tools { myPython3Packages = python3Packages; };

  gdbgui-donation = pkgs.callPackage ./pkgs/gdbgui {};

  inconsolata-nerdfonts = pkgs.callPackage ./pkgs/inconsolata-nerdfonts {};

  inxi = pkgs.callPackage ./pkgs/inxi {};

  nix-lsp = pkgs.callPackage ./pkgs/nix-lsp {
    inherit rustNightlyPlatform;
  };

  nix-review-unstable = pkgs.callPackage ./pkgs/nix-review {};

  oni = pkgs.callPackage ./pkgs/oni {};

  rust-nightly = pkgs.callPackage ./pkgs/rust-nightly {};

  rustNightlyPlatform = pkgs.recurseIntoAttrs (pkgs.makeRustPlatform rust-nightly);

  sourcetrail = pkgs.callPackage ./pkgs/sourcetrail {};

  # smashing = pkgs.callPackage ./pkgs/smashing {};

  perlPackages = {
    Pry = pkgs.callPackage ./pkgs/pry {};
  };

  brotab = pkgs.callPackage ./pkgs/brotab { };

  python2Packages = pkgs.recurseIntoAttrs (pkgs.python2Packages.callPackage ./pkgs/python-pkgs.nix { });
  python3Packages = pkgs.recurseIntoAttrs (pkgs.python3Packages.callPackage ./pkgs/python-pkgs.nix { });

  modules = import ./modules;

  #inherit (callPackages ./node-packages {})
  #  typescript-language-server; # write-good
}
