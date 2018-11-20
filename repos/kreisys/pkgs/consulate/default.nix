{ stdenv, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "consulate-${version}";
  version = "0.0.6";
  rev = "v${version}";

  goPackagePath = "github.com/kadaan/consulate";

  src = fetchFromGitHub {
    inherit rev;
    owner = "kadaan";
    repo  = "consulate";
    sha256 = "1vk62fb8ywpkgj0725gy4sbg1zm9jj223zvdpkfs4v78v1ysv3b6";
  };

  goDeps = ./deps.nix;

  meta = with stdenv.lib; {
    description = "Consul check monitoring endpoint";
    homepage = https://github.com/kadaan/consulate;
    platforms = platforms.linux ++ platforms.darwin;
    license = licenses.asl20;
  };
}
