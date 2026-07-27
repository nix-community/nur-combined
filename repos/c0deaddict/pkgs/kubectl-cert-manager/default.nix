{ stdenv, lib, fetchurl }:

stdenv.mkDerivation rec {
  name = "kubectl-cert-manager";
  version = "1.5.3";

  src = fetchurl {
    url = "https://github.com/jetstack/cert-manager/releases/download/v${version}/kubectl-cert_manager-linux-amd64.tar.gz";
    hash = "sha256-WPtl5bOOY8ZkuSGaWx9VVyfN4rx+f0lc/gDssHjaS0Q=";
  };

  dontUnpack = true;
  sourceRoot = ".";
  installPhase = ''
    mkdir -p $out/bin
    tar xzf $src -C $out/bin
    chmod +x $out/bin/kubectl-cert_manager
  '';  
}
