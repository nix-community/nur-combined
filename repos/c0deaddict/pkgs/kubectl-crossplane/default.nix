{ stdenv, lib, fetchurl }:

let

  channel = "stable";
  version = "v1.4.1";

in stdenv.mkDerivation {
  name = "kubectl-crossplane";
  inherit version;

  src = fetchurl {
    url =
      "https://releases.crossplane.io/${channel}/${version}/bin/linux_amd64/crank";
    # sha256 = lib.fakeSha256;
    sha256 = "090mc5m8bf9gzgxwv6n9lkhzml9jx4jpb3bavzxzrigx8i88fckv";
  };

  dontUnpack = true;
  sourceRoot = ".";
  installPhase = ''
    install -Dm 0555 $src $out/bin/kubectl-crossplane
  '';
}
