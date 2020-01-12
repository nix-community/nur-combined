{ pkgs ? import <nixpkgs> {} }:

rec {
  adminer = pkgs.callPackage ./pkgs/adminer {};

  bitwarden_rs_ldap = pkgs.callPackage ./pkgs/bitwarden_rs_ldap {};

  brotab = pkgs.callPackage ./pkgs/brotab {};

  # TODO checksum can break ... make a mirror?
  # binary-ninja = pkgs.callPackage ./pkgs/binary-ninja {};

  cntr = pkgs.callPackage ./pkgs/cntr {};

  conky-symbols = pkgs.callPackage ./pkgs/conky-symbols {};

  clearsans = pkgs.callPackage ./pkgs/clearsans {};

  eapol_test = pkgs.callPackage ./pkgs/eapol_test {};

  fira-code-nerdfonts = pkgs.callPackage ./pkgs/fira-code-nerdfonts {};

  frida-tools = pkgs.callPackage ./pkgs/frida-tools { myPython3Packages = python3Packages; };

  gdbgui-donation = pkgs.callPackage ./pkgs/gdbgui {};

  gdb-dashboard = pkgs.callPackage ./pkgs/gdb-dashboard {};

  hello-nur = pkgs.callPackage ./pkgs/hello-nur {};

  inconsolata-nerdfonts = pkgs.callPackage ./pkgs/inconsolata-nerdfonts {};

  lualdap = pkgs.callPackage ./pkgs/lualdap {};

  mastodon-hnbot = pkgs.python3Packages.callPackage ./pkgs/mastodon-hnbot {
    inherit (python3Packages) Mastodon;
  };

  mosh-ssh-agent = pkgs.callPackage ./pkgs/mosh-ssh-agent {};

  nix-review-unstable = pkgs.callPackage ./pkgs/nix-review {};

  nixos-shell = pkgs.callPackage ./pkgs/nixos-shell {};

  source-code-pro-nerdfonts = pkgs.callPackage ./pkgs/source-code-pro-nerdfonts {};

  threema-web = pkgs.callPackage ./pkgs/threema-web {};

  xterm-24bit-terminfo = pkgs.callPackage ./pkgs/xterm-24bit-terminfo {};

  # smashing = pkgs.callPackage ./pkgs/smashing {};

  pandoc-bin = pkgs.callPackage ./pkgs/pandoc {};

  phpldapadmin = pkgs.callPackage ./pkgs/phpldapadmin {};

  perlPackages = {
    Pry = pkgs.callPackage ./pkgs/pry {};
  };

  python3Packages = pkgs.recurseIntoAttrs (
    pkgs.python3Packages.callPackage ./pkgs/python-pkgs {}
  );

  yubikey-touch-detector = pkgs.callPackages ./pkgs/yubikey-touch-detector {};

  modules = import ./modules;

  #inherit (pkgs.callPackages ./pkgs/node-packages {})
  #  backport; # write-good typescript-language-server
}
