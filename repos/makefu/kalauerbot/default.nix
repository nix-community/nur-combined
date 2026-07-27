{ stdenv, python3, fetchgit }:
python3.pkgs.buildPythonPackage rec {
name = "kalauerbot";
rev = "08d98aa";
  src = fetchgit {
    url = "http://cgit.euer.krebsco.de/kalauerbot";
    inherit rev;
    sha256 = "017hh61smgq4zsxd10brgwmykwgwabgllxjs31xayvs1hnqmkv2v";
  };
  propagatedBuildInputs = with python3.pkgs;[
    (callPackage ./python-matrixbot.nix {})
    (stdenv.lib.overrideDerivation googletrans (self: {
      patches = [ ./translate.patch ];
    }))
  ];
  checkInputs = [ python3.pkgs.black ];
}

