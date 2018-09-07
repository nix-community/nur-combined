{ stdenv, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "primitive-${version}";
  version = "2017-09-26";

  goPackagePath = "github.com/fogleman/primitive";

  src = fetchFromGitHub {
    owner = "fogleman";
    repo = "primitive";
    rev = "69506c928bef740cc2b04cc385d878083556b206";
    sha256 = "0l37wzx950sfmywbwl28lh888dyaxm56n4qbbdaqx1p1b9n84cdf";
  };

  goDeps = ./deps.nix;

  meta = with stdenv.lib; {
    description = "Reproducing images with geometric primitives";
    homepage = https://primitive.lol/;
    license = licenses.mit;
  };
}
