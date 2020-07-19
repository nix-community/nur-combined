{ pkgs ? import <nixpkgs> { } }:

rec {
  bitwarden_rs_ldap = pkgs.callPackage ./pkgs/bitwarden_rs_ldap { };

  brotab = pkgs.callPackage ./pkgs/brotab {};

  # TODO checksum can break ... make a mirror?
  # binary-ninja = pkgs.callPackage ./pkgs/binary-ninja {};

  check_mk-agent = pkgs.callPackage ./pkgs/check_mk-agent { };

  cntr = pkgs.callPackage ./pkgs/cntr { };

  conky-symbols = pkgs.callPackage ./pkgs/conky-symbols { };

  clearsans = pkgs.callPackage ./pkgs/clearsans { };

  eapol_test = pkgs.callPackage ./pkgs/eapol_test { };

  ferdi = pkgs.callPackage ./pkgs/ferdi { };

  fira-code-pro-nerdfonts = pkgs.nerdfonts.override {
    fonts = [ "FiraCode" ];
  };

  frida-tools = pkgs.callPackage ./pkgs/frida-tools { myPython3Packages = python3Packages; };

  gatttool = pkgs.callPackage ./pkgs/gatttool { };

  gdb-dashboard = pkgs.callPackage ./pkgs/gdb-dashboard { };

  graphene = pkgs.callPackage ./pkgs/graphene { };

  healthcheck = pkgs.callPackage ./pkgs/healthcheck { };

  hello-nur = pkgs.callPackage ./pkgs/hello-nur { };

  keystone = pkgs.callPackage ./pkgs/keystone { };

  kvmtool = pkgs.callPackage ./pkgs/kvmtool { };

  lualdap = pkgs.callPackage ./pkgs/lualdap { };

  mastodon-hnbot = pkgs.python3Packages.callPackage ./pkgs/mastodon-hnbot {
    inherit (python3Packages) Mastodon;
  };

  mosh-ssh-agent = pkgs.callPackage ./pkgs/mosh-ssh-agent { };

  nixpkgs-review-unstable = pkgs.callPackage ./pkgs/nixpkgs-review { };
  # compatibility
  nix-review-unstable = nixpkgs-review-unstable;

  inherit (pkgs.callPackages ./pkgs/nix-build-uncached { })
    nix-build-uncached
    nix-build-uncached-flakes;

  nix-update = pkgs.python3.pkgs.callPackage ./pkgs/nix-update { };

  nixos-shell = pkgs.callPackage ./pkgs/nixos-shell { };

  rspamd-learn-spam-ham = pkgs.python3.pkgs.callPackage ./pkgs/rspam-learn-spam-ham {};

  rhasspyPackages = import ./pkgs/rhasspy {
    inherit (pkgs.python3Packages) callPackage;
  };

  inherit (rhasspyPackages) rhasspy;

  rnix-lsp-unstable = pkgs.callPackage ./pkgs/rnix-lsp { };

  sgx-lkl = pkgs.callPackage ./pkgs/sgx-lkl { };

  source-code-pro-nerdfonts = pkgs.nerdfonts.override {
    fonts = [ "SourceCodePro" ];
  };

  traceshark = pkgs.qt5.callPackage ./pkgs/traceshark { };

  threema-web = pkgs.callPackage ./pkgs/threema-web { };

  # smashing = pkgs.callPackage ./pkgs/smashing {};

  pandoc-bin = pkgs.callPackage ./pkgs/pandoc { };

  patool = pkgs.python3.pkgs.callPackage ./pkgs/patool {
    inherit (pkgs) libarchive;
  };

  peep = pkgs.callPackage ./pkgs/peep { };

  perlPackages = {
    Pry = pkgs.callPackage ./pkgs/pry { };
  };

  phpldapadmin = pkgs.callPackage ./pkgs/phpldapadmin { };

  python3Packages = pkgs.recurseIntoAttrs (
    (pkgs.python3Packages.callPackage ./pkgs/python-pkgs {
      inherit keystone;
    })
  );

  pyps4-2ndscreen = pkgs.python3.pkgs.toPythonApplication python3Packages.pyps4-2ndscreen;

  mypyls = pkgs.python3.pkgs.callPackage ./pkgs/mypyls {};

  term-24bit-terminfo = pkgs.callPackage ./pkgs/xterm-24bit-terminfo { };

  yubikey-touch-detector = pkgs.callPackage ./pkgs/yubikey-touch-detector { };

  modules = import ./modules;

  inherit (pkgs.callPackages ./pkgs/node-packages { }) speedscope;
}
