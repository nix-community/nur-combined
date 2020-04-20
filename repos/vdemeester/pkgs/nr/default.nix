{ stdenv, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  name = "nr-${version}";
  version = "0.4.0";
  rev = "v${version}";

  src = fetchFromGitHub {
    inherit rev;
    owner = "vdemeester";
    repo = "nr";
    sha256 = "1n6plmypw6iz0q1gs4i8rwsmkvx0bwgzpzmrr4qirpfpcyb4av2z";
  };
  modSha256 = "17cz2gahs1j9vd9nqg36q2q04xq24gd2pyvivxkjhqgmq2fcpl17";

  meta = {
    description = "a nix run alias generator";
    homepage = "https://github.com/vdemeester/nr";
    license = lib.licenses.asl20;
  };
}
