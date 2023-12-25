{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "nn";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "meain";
    repo = "${pname}";
    rev = "${version}";
    sha256 = "sha256-qQEu01YXLoGzhqBQmUu/W7jo/aJMZMgpxuUHI9svd58=";
  };

  vendorHash = "sha256-2PeaIokw6wG2JflU4+JlCtv1owkrojRATr0rG/4pAHc=";
  proxyVendor = true;

  meta = with lib; {
    description = " Quick little bot to run shell commands on servers via matrix";
    license = lib.licenses.asl20;
    homepage = "https://github.com/meain/${pname}";
    platforms = platforms.linux ++ platforms.darwin;
  };
}
