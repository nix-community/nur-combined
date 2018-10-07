{ pkgs ? import <nixpkgs> {} }:

rec {
  adminer = pkgs.callPackage ./pkgs/adminer {};

  brotab = pkgs.callPackage ./pkgs/brotab { };

  # TODO checksum can break ... make a mirror?
  # binary-ninja = pkgs.callPackage ./pkgs/binary-ninja {};

  cntr = pkgs.callPackage ./pkgs/cntr {};

  conky-symbols = pkgs.callPackage ./pkgs/conky-symbols {};

  clearsans = pkgs.callPackage ./pkgs/clearsans {};

  doh-proxy = pkgs.python3Packages.callPackage ./pkgs/doh-proxy {
    inherit (python3Packages) aioh2 aiohttp-remotes;
  };

  eapol_test = pkgs.callPackage ./pkgs/eapol_test {};

  frida-tools = pkgs.callPackage ./pkgs/frida-tools { myPython3Packages = python3Packages; };

  gdbgui-donation = pkgs.callPackage ./pkgs/gdbgui {};

  gdb-dashboard = pkgs.callPackage ./pkgs/gdb-dashboard {};

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

  oni = pkgs.callPackage ./pkgs/oni {};

  rainloop = pkgs.callPackage ./pkgs/rainloop {};

  rust-nightly = pkgs.callPackage ./pkgs/rust-nightly {};

  rustNightlyPlatform = pkgs.recurseIntoAttrs (pkgs.makeRustPlatform rust-nightly);

  sourcetrail = pkgs.callPackage ./pkgs/sourcetrail {};

  threema-web = pkgs.callPackage ./pkgs/threema-web {};

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

  modules = import ./modules;

  #inherit (pkgs.callPackages ./pkgs/node-packages {})
  #  backport; # write-good typescript-language-server
}
