{ stdenv, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  name = "ape-${version}";
  version = "0.4.0";
  rev = "v${version}";

  src = fetchFromGitHub {
    inherit rev;
    owner = "vdemeester";
    repo = "ape";
    sha256 = "0lqh34j4ass41vm2jzzrdy1fnhbzibsrysc55595ny1hwcf2kf98";
  };
  modSha256 = "0ffbnfsp25r37b6zgv3clvhjbdlcxp0fsy8bp69pqmzjalrs95b5";

  meta = {
    description = "a git mirror *upstream* updater ";
    homepage = "https://github.com/vdemeester/ape";
    license = lib.licenses.asl20;
  };
}
