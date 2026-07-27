{ lib, callPackage, fetchFromGitHub, npm-buildpackage }:

let
  inherit (npm-buildpackage) buildYarnPackage;
in buildYarnPackage rec {
  src = fetchFromGitHub {
    owner = "iamcco";
    repo = "diagnostic-languageserver";
    rev = "ae1c488da3a3a16d115aeb52bdd925b70ca44e65";
    sha256 = "0npmgssmd9ll40alkdks3pk0wv7r42dxjdah2v60r2bhar0w2dr8";
  };

  preFixup = ''
    mv $out/bin/index $out/bin/diagnostic-languageserver
  '';
}
