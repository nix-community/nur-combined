{ stdenv, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  name = "ape-${version}";
  version = "0.4.1";
  rev = "v${version}";

  src = fetchFromGitHub {
    inherit rev;
    owner = "vdemeester";
    repo = "ape";
    sha256 = "1kh7fi7j65cd8qi5qis38bla4lzbzy0ic18cxcjnd04q1zjqzi2i";
  };
  vendorSha256 = "1zanxsbxhm0dpk2q94fp2rx2x1i8r3j28piz86k3k4vvqnykyvj1";
  modSha256 = "${vendorSha256}";

  meta = {
    description = "a git mirror *upstream* updater ";
    homepage = "https://github.com/vdemeester/ape";
    license = lib.licenses.asl20;
  };
}
