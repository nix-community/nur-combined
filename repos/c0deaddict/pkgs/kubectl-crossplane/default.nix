{ stdenv, lib, fetchurl }:

let

  channel = "stable";
  version = "v1.3.0";

in stdenv.mkDerivation {
  name = "kubectl-crossplane";
  inherit version;

  src = fetchurl {
    url =
      "https://releases.crossplane.io/${channel}/${version}/bin/linux_amd64/crank";
    sha256 = "0gp1c9mkw197hx6mq6lsamwqmm01pnskvrmrb76bh7l4hl4fd94k";
  };

  dontUnpack = true;
  sourceRoot = ".";
  installPhase = ''
    install -Dm 0555 $src $out/bin/kubectl-crossplane
  '';
}
