{ stdenv, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "yubikey-touch-detector-${version}";
  version = "1.2.0";
  rev = "9c160b4a7d5761c518af5d1eaa4a671aa449e773";

  goPackagePath = "github.com/maximbaz/yubikey-touch-detector";

  src = fetchFromGitHub {
    owner = "maximbaz";
    repo = "yubikey-touch-detector";
    rev = version;
    sha256 = "1zifmmadpiamwkgw72dg8s0fcchwga7d3hmywiahha45smbm0zd7";
  };

  goDeps = ./deps.nix;

  meta = with stdenv.lib; {
    description = "Detect when your YubiKey is waiting for a touch";
    license = licenses.mit;
    homepage = https://github.com/maximbaz/yubikey-touch-detector;
  };
}
