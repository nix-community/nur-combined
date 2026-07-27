{ stdenv, lib, buildGoModule, fetchgit }:

buildGoModule rec {
  name = "ram-${version}";
  version = "0.3.2";
  rev = "v${version}";

  src = fetchgit {
    inherit rev;
    url = "https://git.sr.ht/~vdemeester/ram";
    sha256 = "1zjyw699cxylvgh9zakqyylmjrwxwq36g0jls5iwwm75admgqnfr";
  };
  vendorHash = null;

  meta = {
    description = "A golang opiniated continuous testing tool 🐏";
    homepage = "https://git.sr.ht/~vdemeester/ram";
    license = lib.licenses.asl20;
  };
}
