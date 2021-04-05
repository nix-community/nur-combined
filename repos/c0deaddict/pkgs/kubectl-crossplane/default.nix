{ stdenv, lib, fetchurl }:

let

  channel = "stable";
  version = "v1.1.0";

in stdenv.mkDerivation {
  name = "kubectl-crossplane";
  inherit version;

  src = fetchurl {
    url =
      "https://releases.crossplane.io/${channel}/${version}/bin/linux_amd64/crank";
    sha256 = "0rp9q5dl4974p3c65i7w53j7g8h7b9rd260yc9qhlhhc69a92al4";
  };

  dontUnpack = true;
  sourceRoot = ".";
  installPhase = ''
    install -Dm 0555 $src $out/bin/kubectl-crossplane
  '';
}
