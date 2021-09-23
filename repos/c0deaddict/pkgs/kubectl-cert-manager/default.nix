{ stdenv, lib, fetchurl }:

stdenv.mkDerivation rec {
  name = "kubectl-cert-manager";
  version = "1.5.3";

  src = fetchurl {
    url = "https://github.com/jetstack/cert-manager/releases/download/v${version}/kubectl-cert_manager-linux-amd64.tar.gz";
    sha256 = "0i2bv9wb1v00zrf4jzvypkics9spalgmp6i1p5jccqwfngjnbysq";
  };

  dontUnpack = true;
  sourceRoot = ".";
  installPhase = ''
    mkdir -p $out/bin
    tar xzf $src -C $out/bin
    chmod +x $out/bin/kubectl-cert_manager
  '';  
}
