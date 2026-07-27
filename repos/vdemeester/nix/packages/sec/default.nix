{ stdenv, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  name = "sec-${version}";
  version = "0.2.0";
  rev = "v${version}";

  src = fetchFromGitHub {
    inherit rev;
    owner = "vdemeester";
    repo = "sec";
    sha256 = "01xmvycdbyvcjsd1pvbd2qjn4ij99pyyw9sasyffhw0bxfnpcvyq";
  };
  vendorHash = "1b8zis0hv32sh51s01n3z3nd20ayfcj4vv3m943r8d0gqd7hj7zw";
  modHash = "${vendorHash}";

  meta = {
    description = "Sec § — a golang opiniated dependency updater";
    homepage = "https://github.com/vdemeester/sec";
    license = lib.licenses.asl20;
  };
}
