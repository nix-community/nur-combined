{ pkgs ? import <nixpkgs> {} }:

rec {

  browserpass = pkgs.callPackage ./pkgs/tools/security/browserpass {};

  erlang = pkgs.beam.interpreters.erlangR20.override {
    enableDebugInfo = true;
    installTargets = "install";
    wxSupport = false;
  };

  git-crypt = pkgs.callPackage ./pkgs/applications/version-management/git-and-tools/git-crypt {};

  lab = pkgs.callPackage ./pkgs/applications/version-management/git-and-tools/lab {};

  lilypond-unstable = pkgs.stdenv.lib.overrideDerivation pkgs.lilypond-unstable (p: rec {
    majorVersion = "2.19";
    minorVersion = "80";
    version = "${majorVersion}.${minorVersion}";
    name = "lilypond-${version}";
    src = pkgs.fetchurl {
      url = "http://download.linuxaudio.org/lilypond/sources/v${majorVersion}/lilypond-${version}.tar.gz";
      sha256 = "0lql4q946gna2pl1g409mmmsvn2qvnq2z5cihrkfhk7plcqdny9n";
    };
  });

  nodejs = pkgs.nodejs-8_x;

  nodePackages = pkgs.nodePackages //
    pkgs.callPackage ./pkgs/development/node-packages {
      inherit pkgs;
      inherit nodejs;
    };

  sourcetree = pkgs.callPackage ./pkgs/os-specific/darwin/sourcetree {};

}
