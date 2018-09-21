{ stdenv, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "consulate-${version}";
  version = "0.0.5";
  rev = "v${version}";

  goPackagePath = "github.com/kadaan/consulate";

  src = fetchFromGitHub {
    inherit rev;
    owner = "kadaan";
    repo  = "consulate";
    sha256 = "12gw78fm05l72nn8h0brc0w3190c1algsvb3pnahn022m7pklkmx";
  };

  goDeps = ./deps.nix;

  meta = with stdenv.lib; {
    description = "Consul check monitoring endpoint";
    homepage = https://github.com/kadaan/consulate;
    platforms = platforms.linux ++ platforms.darwin;
    license = licenses.asl20;
  };
}
