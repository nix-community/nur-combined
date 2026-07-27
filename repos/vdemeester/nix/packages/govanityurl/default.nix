{ stdenv, lib, buildGoModule, fetchgit }:

buildGoModule rec {
  pname = "govanityurl";
  name = "${pname}-${version}";
  version = "0.1.0";

  src = fetchgit {
    url = "https://git.sr.ht/~vdemeester/vanityurl";
    rev = "v${version}";
    sha256 = "sha256-7AdNbbIcNSPRAi8u0+2b/Lscq4MFXci0+WeND8wZkhU=";
  };
  vendorHash = "sha256-qe7SxvrmgbcUnBUbUVx/l3hLZ1BRHZyDgi8tLtULCms=";
}
