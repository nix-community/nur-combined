{ pkgs ? import <nixpkgs> {} }:

rec {
  adminer = pkgs.callPackage ./pkgs/adminer {};

  brotab = pkgs.callPackage ./pkgs/brotab { };

  # TODO checksum can break ... make a mirror?
  # binary-ninja = pkgs.callPackage ./pkgs/binary-ninja {};

  cntr = pkgs.callPackage ./pkgs/cntr {};

  conky-symbols = pkgs.callPackage ./pkgs/conky-symbols {};

  clearsans = pkgs.callPackage ./pkgs/clearsans {};

  eapol_test = pkgs.callPackage ./pkgs/eapol_test {};

  esptool = pkgs.python3.pkgs.callPackage ./pkgs/esptool {};

  fira-code-nerdfonts = pkgs.callPackage ./pkgs/fira-code-nerdfonts {};

  frida-tools = pkgs.callPackage ./pkgs/frida-tools { myPython3Packages = python3Packages; };

  gdbgui-donation = pkgs.callPackage ./pkgs/gdbgui {};

  gdb-dashboard = pkgs.callPackage ./pkgs/gdb-dashboard {};

  glowing-bear = pkgs.callPackage ./pkgs/glowing-bear {};

  inconsolata-nerdfonts = pkgs.callPackage ./pkgs/inconsolata-nerdfonts {};

  inxi = pkgs.callPackage ./pkgs/inxi {};

  lualdap = pkgs.callPackage ./pkgs/lualdap {};

  mastodon-hnbot = pkgs.python3Packages.callPackage ./pkgs/mastodon-hnbot {
    inherit (python3Packages) Mastodon;
  };

  nix-lsp = pkgs.callPackage ./pkgs/nix-lsp {
    inherit rustNightlyPlatform;
  };

  nix-review-unstable = pkgs.callPackage ./pkgs/nix-review {};

  nixos-shell = pkgs.callPackage ./pkgs/nixos-shell {};

  oni = pkgs.callPackage ./pkgs/oni {};

  rust-nightly = pkgs.callPackage ./pkgs/rust-nightly {};

  rustNightlyPlatform = pkgs.recurseIntoAttrs (pkgs.makeRustPlatform rust-nightly);

  source-code-pro-nerdfonts = pkgs.callPackage ./pkgs/source-code-pro-nerdfonts {};

  threema-web = pkgs.callPackage ./pkgs/threema-web {};

  xterm-24bit-terminfo = pkgs.callPackage ./pkgs/xterm-24bit-terminfo {};

  # smashing = pkgs.callPackage ./pkgs/smashing {};

  phpldapadmin = pkgs.callPackage ./pkgs/phpldapadmin {};

  purple-skypeweb = pkgs.callPackage ./pkgs/purple-skypeweb {};

  perlPackages = {
    Pry = pkgs.callPackage ./pkgs/pry {};
  };

  python2Packages = pkgs.recurseIntoAttrs (
    pkgs.python2Packages.callPackage ./pkgs/python-pkgs { }
  );
  python3Packages = pkgs.recurseIntoAttrs (
    pkgs.python3Packages.callPackage ./pkgs/python-pkgs { }
  );


  yubikey-touch-detector = pkgs.callPackages ./pkgs/yubikey-touch-detector { };

  modules = import ./modules;

  #inherit (pkgs.callPackages ./pkgs/node-packages {})
  #  backport; # write-good typescript-language-server
}
